From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of	netif_rx()
Date: Mon, 31 Mar 2008 12:01:16 +0200
Message-ID: <47F0B66C.6080404@cosmosbay.com>
References: <47BDC848.50607@cosmosbay.com> <20080226.182120.183405235.davem@davemloft.net> <47C92F49.4070100@cosmosbay.com> <20080323.032949.194309002.davem@davemloft.net> <47E6A5FD.6060407@cosmosbay.com> <20080331094823.GA11651@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756458AbYCaKBm@vger.kernel.org>
In-Reply-To: <20080331094823.GA11651@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar a =E9crit :
> * Eric Dumazet <dada1@cosmosbay.com> wrote:
>
>  =20
>> I noticed some paths in kernel are very stack aggressive, and on i38=
6=20
>> with CONFIG_4KSTACKS we were really in a dangerous land, even withou=
t=20
>> my patch.
>>
>> What we call 4K stacks is in fact 4K - sizeof(struct task_struct), s=
o=20
>> a litle bit more than 2K. [...]
>>    =20
>
> that's just wrong - 4K stacks on x86 are 4K-sizeof(thread_info) - the=
=20
> task struct is allocated elsewhere. The patch below runs just fine on=
=20
> 4K-stack x86.
>
>  =20
Yes, this error was corrected by Andi already :)

Thank you Ingo but this patch was already suggested by me previously (=20
http://marc.info/?l=3Dlinux-netdev&m=3D120361996713007&w=3D2 ) and was=20
rejected, since we can very easily consume all stack space, especially=20
with 4K stacks.
(try with NFS mounts and XFS for example)



Only safe way is to check available free stack space, since we can nest=
 =20
loopback_xmit() several time.
In case of protocol errors (like in TCP, if we answer to an ACK by=20
another ACK, or ICMP loops), we would exhaust stack instead of delaying=
=20
packets for next softirq run.

Problem is to check available space :

It depends on stack growing UP or DOWN, and depends on caller running o=
n=20
process stack, or softirq stack, or even hardirq stack.




> 	Ingo
>
> ------------->
> Subject: net: loopback speedup
> From: Ingo Molnar <mingo@elte.hu>
> Date: Mon Mar 31 11:23:21 CEST 2008
>
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> ---
>  drivers/net/loopback.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: linux/drivers/net/loopback.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.orig/drivers/net/loopback.c
> +++ linux/drivers/net/loopback.c
> @@ -158,7 +158,7 @@ static int loopback_xmit(struct sk_buff=20
>  	lb_stats->bytes +=3D skb->len;
>  	lb_stats->packets++;
> =20
> -	netif_rx(skb);
> +	netif_receive_skb(skb);
> =20
>  	return 0;
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>
>  =20
