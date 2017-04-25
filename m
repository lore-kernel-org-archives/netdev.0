From: Erez Shitrit <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH] IB/IPoIB: Check the headroom size
Date: Tue, 25 Apr 2017 14:11:18 +0300
Message-ID: <CAAk-MO8O19iC2Yn-BMn5pKTAYxaSzGPMyta=fwes3XSvzmz_cQ@mail.gmail.com>
References: <1493114155-12101-1-git-send-email-honli@redhat.com> <CAJ3xEMg4_2ph7QwPsUb-tX-K4d2ppkqz98sPzytsmBCK=29WHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Honggang LI <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJ3xEMg4_2ph7QwPsUb-tX-K4d2ppkqz98sPzytsmBCK=29WHw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 25, 2017 at 1:32 PM, Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, Apr 25, 2017 at 12:55 PM, Honggang LI <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> From: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>
>> Minimal hard_header_len set by bond_compute_features is ETH_HLEN, which
>> is smaller than IPOIB_HARD_LEN. ipoib_hard_header should check the
>> size of headroom to avoid skb_under_panic.
>
> sounds terrible, ipoib bonding is supported since ~2007, thanks for
> reporting on that.
>
>> [  122.871493] ipoib_hard_header: skb->head= ffff8808179d9400, skb->data= ffff8808179d9420, skb_headroom= 0x20
>> [  123.055400] bond0: Releasing backup interface mthca_ib1
>> [  123.560529] bond_compute_features:1112 bond0 bond_dev->hard_header_len = 14
>> [  123.568822] CPU: 0 PID: 12336 Comm: ifdown-ib Not tainted 4.9.0-debug #1
>
> did you generate this trace by calling dump_stack or this is existing
> kernel code.
>
>> Fixes: fc791b633515 ('IB/ipoib: move back IB LL address into the hard header')
>
> this is more of WA to avoid some crash or failure but not fixing the
> actual problem
>
> Erez, can you comment?

We saw that after commit fc791b633515, it happened while removing bond
interface after its slaves (ipoib interface) removed.
At that point the bond interface sets its dev_harheader_len to be as
eth interfaces (14 instead of 24), and if a process which doesn't
aware of the slaves removal or was at the middle of the sending tries
to send (igmp) packet it goes to ipoib with no space in the skb for
it, and here comes the panic.

I agree with you that this fix is w/a, and it is a fix in the data
path for all the packets while the panic is in a control flow. It
probably should be fixed in the bonding driver.

>
> Or.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
