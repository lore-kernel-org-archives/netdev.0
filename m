From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Thu, 08 Sep 2011 08:27:29 +0800
Message-ID: <4E680BF1.8000901@intel.com>
References: <4E631032.6050606@intel.com>  <1315326326.2576.2980.camel@schen9-DESK>  <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1315335019.2576.3048.camel@schen9-DESK>  <1315335660.3400.7.camel@edumazet-laptop>  <1315337580.2576.3066.camel@schen9-DESK>  <1315338186.3400.20.camel@edumazet-laptop>  <1315339157.2576.3079.camel@schen9-DESK>  <1315340388.3400.28.camel@edumazet-laptop>  <CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com>  <1315372100.3400.76.camel@edumazet-laptop> <4E66FF38.9000107@intel.com>  <1315381503.3400.85.camel@edumazet-laptop>  <1315396903.2364.23.camel@schen9-mobl>  <CA+icZUVqJVn4ONuSDV5YdgpEcmetVMM9X=Sxt2EqM8qdegMnjQ@mail.gmail.com>  <CA+icZUW5Biu8cMhaJcz=MwtMOVn-NFD92PTpT0-DfEDKrRmaUQ@mail.gmail.com> <1315406256.6287.7.camel@schen
 9-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "sedat.dilek@gmail.com" <sedat.dilek@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6546 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756557Ab1IHA1k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 20:27:40 -0400
In-Reply-To: <1315406256.6287.7.camel@schen9-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2011 10:37 PM, Tim Chen wrote:
> On Wed, 2011-09-07 at 22:30 +0200, Sedat Dilek wrote:
> 
>>>
>>> Replaced v2 with this patch (against next-20110831), I see now some
>>> different call-traces which I did not see with v1 or v2.
>>> Can't say if it's related to the new patch or not.
>>> ( dmesg attached. )
>>>
>>> - Sedat -
>>>
>>
>> Call-traces seem to go away when adding "irqpoll" to Kernel command line.
>> ( See dmesg_irqpoll.txt )
>>
>> - Sedat -
> 
> Sedat,
>  
> The previous patch should use the new steal_refs to check for the
> release of scm references in the error handling at the end.  I've
> updated the patch to take care of it.  Hopefully the traces you see will
> go away. Can you verify?
> 
> Thanks.
> 
> Tim
> 
> ----
> Commit 0856a30409 (Scm: Remove unnecessary pid & credential references
> in Unix socket's send and receive path) introduced a use-after-free bug.
> The sent skbs from unix_stream_sendmsg could be consumed and destructed 
> by the receive side, removing all referentials to the credentials, 
> before the send side has finished sending out all 
> packets. However, send side could continue to consturct new packets in the 
> stream, using credentials that have lost its last reference and been
> freed.  
> 
> In this fix, we don't steal the reference to credentials we have obtained 
> in scm_send at beginning of unix_stream_sendmsg, till we've reached
> the last packet.  This fixes the problem in commit 0856a30409.
> 
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Reported-by: Jiri Slaby <jirislaby@gmail.com>
> Tested-by: Sedat Dilek <sedat.dilek@googlemail.com>
> Tested-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
> ---
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 136298c..be712ae 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1383,10 +1383,11 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
>  }
>  
>  static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb,
> -			   bool send_fds, bool ref)
> +			   bool send_fds, bool steal_refs)
>  {
>  	int err = 0;
> -	if (ref) {
> +
> +	if (!steal_refs) {
>  		UNIXCB(skb).pid  = get_pid(scm->pid);
>  		UNIXCB(skb).cred = get_cred(scm->cred);
>  	} else {
> @@ -1458,7 +1459,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  	if (skb == NULL)
>  		goto out;
>  
> -	err = unix_scm_to_skb(siocb->scm, skb, true, false);
> +	err = unix_scm_to_skb(siocb->scm, skb, true, true);
>  	if (err < 0)
>  		goto out_free;
>  	max_level = err + 1;
> @@ -1581,6 +1582,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  	int sent = 0;
>  	struct scm_cookie tmp_scm;
>  	bool fds_sent = false;
> +	bool steal_refs = false;
>  	int max_level;
>  
>  	if (NULL == siocb->scm)
> @@ -1642,11 +1644,14 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  		size = min_t(int, size, skb_tailroom(skb));
>  
>  
> -		/* Only send the fds and no ref to pid in the first buffer */
> -		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds_sent);
> +		/* Only send the fds in first buffer
> +		 * Last buffer can steal our references to pid/cred
> +		 */
> +		steal_refs = (sent + size >= len);
> +		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, steal_refs);
>  		if (err < 0) {
>  			kfree_skb(skb);
> -			goto out;
> +			goto out_err;
>  		}
>  		max_level = err + 1;
>  		fds_sent = true;
> @@ -1654,7 +1659,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
>  		if (err) {
>  			kfree_skb(skb);
> -			goto out;
> +			goto out_err;
>  		}
>  
>  		unix_state_lock(other);
> @@ -1671,7 +1676,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  		sent += size;
>  	}
>  
> -	if (skb)
> +	if (steal_refs)
>  		scm_release(siocb->scm);
>  	else
>  		scm_destroy(siocb->scm);
> @@ -1687,9 +1692,8 @@ pipe_err:
>  		send_sig(SIGPIPE, current, 0);
>  	err = -EPIPE;
>  out_err:
> -	if (skb == NULL)
> +	if (!steal_refs)
>  		scm_destroy(siocb->scm);

I think we should call scm_release() here in the case of
steal_refs == true. Otherwise siocb->scm->fp may leak.
> -out:
>  	siocb->scm = NULL;
>  	return sent ? : err;
>  }
> 
> 
