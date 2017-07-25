From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] TLP: Don't reschedule PTO when there's one
 outstanding TLP retransmission.
Date: Tue, 25 Jul 2017 12:54:31 +0300
Message-ID: <549b181d-b925-35ca-193c-2bc641ab901a@cogentembedded.com>
References: <1500971735-21852-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Mao Wenan <maowenan@huawei.com>, netdev@vger.kernel.org,
        davem@davemloft.net, weiyongjun1@huawei.com, chenweilong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:32851 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdGYJyd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 05:54:33 -0400
Received: by mail-lf0-f54.google.com with SMTP id p2so38613602lfg.0
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 02:54:32 -0700 (PDT)
In-Reply-To: <1500971735-21852-1-git-send-email-maowenan@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 7/25/2017 11:35 AM, Mao Wenan wrote:

> If there is one TLP probe went out(TLP use the write_queue_tail packet
> as TLP probe, we assume this first TLP probe named A), and this TLP
> probe was not acked by receive side.
> 
> Then the transmit side sent the next two packetes out(named B,C), but
> unfortunately these two packets are also not acked by receive side.
> 
> And then there is one data packet with ack_seq A arrive, in tcp_ack()
> will call tcp_schedule_loss_probe() to rearm PTO, the handler
> tcp_send_loss_probe() pass if(tp->tlp_high_seq)(because there is
> one outstanding TLP named A,tp->tlp_high_seq is not zero),
> so the new TLP probe can't be went out and need to rearm the RTO
> timer(timeout is relative to the transmit time of the write queue head).
> 
> After this, another data packet with ack_seq A is received,
> if the tlp_time_stamp is after rto_time_stamp, it will reset the
> TLP timeout with delta value, which is before previous RTO timeout,
> so PTO is rearm and previous RTO is cleared. This TLP probe also can't
> be sent out because of tp->tlp_high_seq != 0, so there is no way(or need
> very long time)to retransmit the packet because of TLP A is lost.
> 
> This fix is not to pass the if(tp->tlp_high_seq) in tcp_schedule_loss_probe()
> when TLP PTO is after RTO, It is no need to reschedule PTO when there
> is one outstanding TLP retransmission, so if the TLP A is lost then RTO can
> retransmit that packet, and tp->tlp_high_seq will be set to 0. After this TLP
> will go to the normal work process.
> 
> Signed-off-by: Mao Wenan <maowenan@huawei.com>
> ---
>   net/ipv4/tcp_output.c | 4 ++++
>   1 file changed, 4 insertions(+)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 886d874..0c8da1c 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2423,6 +2423,10 @@ bool tcp_schedule_loss_probe(struct sock *sk)
>   	tlp_time_stamp = tcp_jiffies32 + timeout;
>   	rto_time_stamp = (u32)inet_csk(sk)->icsk_timeout;
>   	if ((s32)(tlp_time_stamp - rto_time_stamp) > 0) {
> +		/*It is no need to reschedule PTO when there is one outstanding TLP retransmission*/

    Please add space after /* and before */

> +		if (tp->tlp_high_seq) {
> +			return false;
> +		}

    {} not needed.

[...]

MBR, Sergei
