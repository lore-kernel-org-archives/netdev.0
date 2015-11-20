From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 4/6] kcm: Kernel Connection Multiplexor module
Date: Fri, 20 Nov 2015 17:50:12 -0500
Message-ID: <20151120225012.GB10508@oracle.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
 <1448054520-1464587-5-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
	davewatson@fb.com, alexei.starovoitov@gmail.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36175 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130AbbKTWuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 17:50:21 -0500
Content-Disposition: inline
In-Reply-To: <1448054520-1464587-5-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (11/20/15 13:21), Tom Herbert wrote:
> +static int kcm_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
   :
> +
> +		if (msg->msg_flags & MSG_BATCH) {
> +			kcm->tx_wait_more = true;
> +		} else if (kcm->tx_wait_more || not_busy) {
> +			err = kcm_write_msgs(kcm);
> +			if (err < 0) {
> +				/* We got a hard error in write_msgs but have
> +				 * already queued this message. Report an error
> +				 * in the socket, but don't affect return value
> +				 * from sendmsg
> +				 */
> +				pr_warn("KCM: Hard failure on kcm_write_msgs\n");
> +				report_csk_error(&kcm->sk, -err);
> +			}
> +		}

It's interesting that kcm copies the user data to a skb and
then invokes kernel_sendpage on the frag_list in that skb- was this 
specifically done with some perf goals in mind? If yes, do you happen
to have some estimate of how much this approach buys you, as opposed
to just setting up a sglist and calling tcp_sendpage later? (RDS uses
the latter approach, and I've tried to use the changes introduced
by Eric's commit in 5640f76, it helps slightly but I think there may
be other bottlenecks to overcome first for the specific req-resp
patterns that are common in DB workloads)

The other question I had when reading this code is: what if the
application never sends that last MSG_BATCH-less message, e.g.,
it lies about how its going send more messages? will something eventually
time-out and send the data? Any estimates for a good batch size?

--Sowmini
