From: Philipp Hahn <pmhahn@pmhahn.de>
Subject: Re: [PATCH net] af_unix: Guard against other == sk in
 unix_dgram_sendmsg
Date: Fri, 12 Feb 2016 10:19:36 +0100
Message-ID: <56BDA3A8.6070807@pmhahn.de>
References: <56B4BF9D.9070609@pmhahn.de> <56BC90E7.7040007@pmhahn.de>
 <87fuwzkzr5.fsf@doppelsaurus.mobileactivedefense.com>
 <1455210224.2801.21.camel@decadent.org.uk>
 <87r3gjjgbu.fsf@doppelsaurus.mobileactivedefense.com>
 <87egcjcd5j.fsf@doppelsaurus.mobileactivedefense.com>
 <87r3gj11jc.fsf_-_@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Karolin Seeger <kseeger@samba.org>,
	Jason Baron <jbaron@akamai.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arvid Requate <requate@univention.de>,
	Stefan Gohmann <gohmann@univention.de>, netdev@vger.kernel.org
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87r3gj11jc.fsf_-_@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Rainer,

Am 11.02.2016 um 20:37 schrieb Rainer Weikusat:
> The unix_dgram_sendmsg routine use the following test
> 
> if (unlikely(unix_peer(other) != sk && unix_recvq_full(other))) {
> 
> to determine if sk and other are in an n:1 association (either
> established via connect or by using sendto to send messages to an
> unrelated socket identified by address). This isn't correct as the
> specified address could have been bound to the sending socket itself or
> because this socket could have been connected to itself by the time of
> the unix_peer_get but disconnected before the unix_state_lock(other). In
> both cases, the if-block would be entered despite other == sk which
> might either block the sender unintentionally or lead to trying to unlock
> the same spin lock twice for a non-blocking send. Add a other != sk
> check to guard against this.
> 
> Fixes: 7d267278a9ec ("unix: avoid use-after-free in ep_remove_wait_queue")
> Reported-By: Philipp Hahn <pmhahn@pmhahn.de>
> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> ---
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 29be035..f1ca279 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1781,7 +1781,12 @@ restart_locked:
>  			goto out_unlock;
>  	}
>  
> -	if (unlikely(unix_peer(other) != sk && unix_recvq_full(other))) {
> +	/* other == sk && unix_peer(other) != sk if
> +	 * - unix_peer(sk) == NULL, destination address bound to sk
> +	 * - unix_peer(sk) == sk by time of get but disconnected before lock
> +	 */
> +	if (other != sk &&
> +	    unlikely(unix_peer(other) != sk && unix_recvq_full(other))) {
>  		if (timeo) {
>  			timeo = unix_wait_for_peer(other, timeo);
>  
> 

After applying that patch at least my machine running the samba test no
longer crashes. So you might add
Tested-by: Philipp Hahn <pmhahn@pmhahn.de>

Thanks for looking it that issues.

Philipp
