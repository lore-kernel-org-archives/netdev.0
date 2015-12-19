From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] veth: don't modify ip-summed; doing so treats packets
 with bad checksums as good.
Date: Sat, 19 Dec 2015 13:34:31 -0800
Message-ID: <CAHA+R7Oium7-Zj_TKOL4qOTiEUmzsykO2UPf4M9Gt0DS8ABt0g@mail.gmail.com>
References: <CAKoqxG=R566bG2sQzWabAaaoUZjUJfoVP7k7dcYK4QuEcH0jrA@mail.gmail.com>
	<CAM_iQpUOKGoNNDF2Nbut8a0q2rGY6pCXBm3NVkBMe=63K7L9bg@mail.gmail.com>
	<CAKUBDd-VfaBvdMDJE8_mH2vXKn-66PM_0i-ioJLm6yQgwbrE4A@mail.gmail.com>
	<CAM_iQpVAZ=C68f1BGNEV=e-WGaJrvR-pzu_6kqCGnJLo8gw6Pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vijay Pandurangan <vijayp@vijayp.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Evan Jones <ej@evanjones.ca>, Tom Herbert <tom@herbertland.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVAZ=C68f1BGNEV=e-WGaJrvR-pzu_6kqCGnJLo8gw6Pg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 19, 2015 at 1:01 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Dec 18, 2015 at 11:42 AM, Vijay Pandurangan <vijayp@vijayp.ca> wrote:
>> Evan and I have demonstrated this bug on Kubernetes as well, so it's
>> not just a problem in Mesos. (See
>> https://github.com/kubernetes/kubernetes/issues/18898)
>>
>
> Interesting... then this problem is much more serious than I thought.
>
> Looks like in RX path the bridge sets the checksum to CHECKSUM_NONE
> too:
>
> static inline void skb_forward_csum(struct sk_buff *skb)
> {
>         /* Unfortunately we don't support this one.  Any brave souls? */
>         if (skb->ip_summed == CHECKSUM_COMPLETE)
>                 skb->ip_summed = CHECKSUM_NONE;
> }
>
> I guess this is probably why Docker/Kubernetes could be affected too.

Hmm, no, actually this is due to netem does the software checksum
and sets it to CHECKSUM_NONE:

        if (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor)) {
                if (!(skb = skb_unshare(skb, GFP_ATOMIC)) ||
                    (skb->ip_summed == CHECKSUM_PARTIAL &&
                     skb_checksum_help(skb)))
                        return qdisc_drop(skb, sch);

                skb->data[prandom_u32() % skb_headlen(skb)] ^=
                        1<<(prandom_u32() % 8);
        }


But anyway, your patch still looks correct to me.
