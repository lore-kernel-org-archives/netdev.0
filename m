From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC 0/3] tun zerocopy stats
Date: Thu, 12 Oct 2017 19:21:12 +0800
Message-ID: <c86cc1a3-468f-3fa6-c8fc-ce85cc7f2e61@redhat.com>
References: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
 <20171009.205228.714368596112967819.davem@davemloft.net>
 <CAF=yD-Jc_ikdYLydYwkw+h_+izVEg2Qp66=5+URokyqM=E=zJg@mail.gmail.com>
 <20171010.103918.358738948563291074.davem@davemloft.net>
 <CAF=yD-J+Abjka9PViEFE6OhKOWf65UK1do5prYboFC+m+Tv1wA@mail.gmail.com>
 <3ef92f5f-b242-a66a-860f-31da29216dc4@redhat.com>
 <CAF=yD-++Vn6UbDm5q7_wpwx90Wt-Yia+g4ju_cJ+rX34tt7JPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33116 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752410AbdJLLVS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Oct 2017 07:21:18 -0400
In-Reply-To: <CAF=yD-++Vn6UbDm5q7_wpwx90Wt-Yia+g4ju_cJ+rX34tt7JPw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年10月12日 05:44, Willem de Bruijn wrote:
> On Tue, Oct 10, 2017 at 11:15 PM, Jason Wang <jasowang@redhat.com> wrote:
>>
>> On 2017年10月11日 03:11, Willem de Bruijn wrote:
>>> On Tue, Oct 10, 2017 at 1:39 PM, David Miller <davem@davemloft.net> wrote:
>>>> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
>>>> Date: Tue, 10 Oct 2017 11:29:33 -0400
>>>>
>>>>> If there is a way to expose these stats through vhost_net directly,
>>>>> instead of through tun, that may be better. But I did not see a
>>>>> suitable interface. Perhaps debugfs.
>>>> Please don't use debugfs, thank you :-)
>>> Okay. I'll take a look at tracing for on-demand measurement.
>>
>> This reminds me a past series that adding tracepoints to vhost/net[1]. It
>> can count zero/datacopy independently and even contains a sample program to
>> show the stats.
> Interesting, thanks!
>
> For occasional evaluation, we can also use a bpf kprobe for the time being:
>
>    bpf_program = """
>    #include <uapi/linux/ptrace.h>
>    #include <bcc/proto.h>
>
>    BPF_ARRAY(count, u64, 2);
>
>    void inc_counter(struct pt_regs *ctx) {
>        bool success;
>        int key;
>        u64 *val;
>
>        success = PT_REGS_PARM2(ctx);
>        key = success ? 0 : 1;
>        val = count.lookup(&key);
>        if (val)
>            lock_xadd(val, 1);
>    }
>    """
>
>    b = bcc.BPF(text=bpf_program)
>    b.attach_kprobe(event="vhost_zerocopy_callback", fn_name="inc_counter")
>
>    time.sleep(5)
>
>    print("vhost_zerocopy_callback: Y:%d N:%d" %
>          (b["count"][ctypes.c_int(0)].value,
>           b["count"][ctypes.c_int(1)].value))

Thanks for the tips, looks flexible.
