From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] net/sctp: always initialise sctp_ht_iter::start_fail
Date: Sat, 23 Jul 2016 11:15:33 -0300
Message-ID: <20160723141532.GH9950@localhost.localdomain>
References: <1469267543-24650-1-git-send-email-vegard.nossum@oracle.com>
 <20160723133929.GG9950@localhost.localdomain>
 <57937887.6030204@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Xin Long <lucien.xin@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Eric W. Biederman" <ebiederm@xmission.com>, stable@vger.kernel.org
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57937887.6030204@oracle.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 23, 2016 at 04:00:39PM +0200, Vegard Nossum wrote:
> On 07/23/2016 03:39 PM, Marcelo Ricardo Leitner wrote:
> > On Sat, Jul 23, 2016 at 11:52:23AM +0200, Vegard Nossum wrote:
> > > seq_read() can call ->start() twice on the same iterator more than once
> > > (e.g. once through traverse() and once in seq_read() itself).
> > 
> > But when traverse() returns the error, it goes to Done label, skipping
> > the call to ->start() from seq_read(), or am I missing something?
> 
> I think you're right.
> 
> > Though yes, if sctp_ht_iter memory is actually re-used without
> > initializting between seq_read()s, it triggers the issue you described.
> 
> The sctp_ht_iter is allocated in
> sctp_assocs_seq_open()/sctp_remaddr_seq_open(), so I assume it's
> allocated on open().
> 
> > How did you trigger this, reading after an error on the file descriptor?
> 
> I was using trinity, so I'm not quite sure a priori, but the problem was
> 100% reproducible before I applied the patch and seeing that it gets
> allocated on open() and is never cleared anywhere else, your suggestion
> sounds like the most plausible explanation :-)
> 
> How about rewording the first paragraph as:
> 
> """
> sctp_transport_seq_start() does not currently clear iter->start_fail on
> success, but relies on it being zero when it is allocated (by
> seq_open_net()).
> 
> This can be a problem in the following sequence:
> 
> open() -- allocates iter (and implicitly sets iter->start_fail = 0)
> read()
>  iter->start() -- fails and sets iter->start_fail = 1
>  iter->stop() -- doesn't call sctp_transport_walk_stop() (correct)
> read() again
>  iter->start() -- succeeds, but doesn't change iter->start_fail
>  iter->stop() -- doesn't call sctp_transport_walk_stop() (wrong)
> """
> 
> Let me know how that sounds.

LGTM, thanks!

  Marcelo

> 
> Thanks for looking so closely at it!
> 
> 
> Vegard
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
