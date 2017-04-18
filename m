From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/ipv6: slab-out-of-bounds read in seg6_validate_srh
Date: Tue, 18 Apr 2017 17:46:43 +0200
Message-ID: <CAAeHK+xQQGw8bcYwt-=qWREngrR+bg-9Tyy6GfEf1S2Okq-pWQ@mail.gmail.com>
References: <CAAeHK+zcuT0Y2Xmh0C0JB0Cv9JYoh13tOqw5qKGj+nANZT_axw@mail.gmail.com>
 <bd8d4b77-ee74-73a7-55af-404a1b666460@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <bd8d4b77-ee74-73a7-55af-404a1b666460@uclouvain.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 18, 2017 at 5:16 PM, David Lebrun <david.lebrun@uclouvain.be> wrote:
> On 04/18/2017 04:54 PM, Andrey Konovalov wrote:
>> Hi,
>>
>> I've got the following error report while fuzzing the kernel with syzkaller.
>>
>> On commit 4f7d029b9bf009fbee76bb10c0c4351a1870d2f3 (4.11-rc7).
>>
>> A reproducer and .config are attached.
>>
>> ==================================================================
>> BUG: KASAN: slab-out-of-bounds in seg6_validate_srh+0x203/0x220
>> net/ipv6/seg6.c:57 at addr ffff88006a759608
>> Read of size 1 by task syz-executor4/2627
>
> Thanks for the report. It seems to happen when the trailing data is less
> than sizeof(struct sr6_tlv). The following (untested) patch should fix
> the issue, I'll test it and submit it properly if it works.

Hi David,

This fixes the bug.

Thanks!

Tested-by: Andrey Konovalov <andreyknvl@google.com>

>
> diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
> index a855eb3..5f44ffe 100644
> --- a/net/ipv6/seg6.c
> +++ b/net/ipv6/seg6.c
> @@ -53,6 +53,9 @@ bool seg6_validate_srh(struct ipv6_sr_hdr *srh, int len)
>                 struct sr6_tlv *tlv;
>                 unsigned int tlv_len;
>
> +               if (trailing < sizeof(*tlv))
> +                       return false;
> +
>                 tlv = (struct sr6_tlv *)((unsigned char *)srh + tlv_offset);
>                 tlv_len = sizeof(*tlv) + tlv->len;
>
>
>
