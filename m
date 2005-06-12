From: Willy Tarreau <willy@w.ods.org>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sun, 12 Jun 2005 14:32:53 +0200
Message-ID: <20050612123253.GK28759__32415.0082575672$1118579464$gmane$org@alpha.home.local>
References: <20050611074350.GD28759@alpha.home.local> <E1DhBic-0005dp-00@gondolin.me.apana.org.au> <20050611195144.GF28759@alpha.home.local> <20050612081327.GA24384@gondor.apana.org.au> <20050612083409.GA8220@alpha.home.local> <20050612103020.GA25111@gondor.apana.org.au> <20050612114039.GI28759@alpha.home.local> <20050612120627.GA5858@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xschmi00@stud.feec.vutbr.cz, alastair@unixtrix.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050612120627.GA5858@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jun 12, 2005 at 10:06:27PM +1000, Herbert Xu wrote:
> On Sun, Jun 12, 2005 at 01:40:39PM +0200, Willy Tarreau wrote:
> >
> > Sorry Herbert, but both RFC793 page 32 figure 9 and my Linux box disagree
> > with this statement. Look: at line 5, A rejects the SYN-ACK because the
> > ACK is wrong during the session setup.
> 
> Look at the first check inside th->ack in tcp_rcv_synsent_state_process.

Herbert, I perfectly agree with this check and it's consistent with what I
observe. But as you know, there's a difference between resetting a session
and sending an RST to say that we refuse a segment. This check does not kill
the session, it sends an RST whose SEQ is equal to the SYN-ACK's ACK. It's
possible you though the "reset_and_undo" label was used to kill the session,
but it's not the case (although the naming is not clear). So if the remote
end was the one which sent the SYN-ACK, it will clear its session. If it has
been spoofed, it will ignore the RST because in turn, the SEQ will not be
within its window.

Try it by yourself if you don't believe me. I've done lots of tests with
hping2 and I've never managed to kill a session with both a SEQ and ACK
outside the windows.

Regards,
Willy
