From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [oss-drivers] Re: [PATCH/RFC net-next 2/2] net/sched: allow
 flower to match tunnel options
Date: Wed, 13 Sep 2017 15:38:01 +0300
Message-ID: <CAJ3xEMj9HYj+2-ruxLk=PVt=Gxu3FwpyrJPRUgCqdsNamZ=Txw@mail.gmail.com>
References: <1505226037-2758-1-git-send-email-simon.horman@netronome.com>
 <1505226037-2758-3-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgfkpJCfZX-7jaeYtoWTSQQZ6gu8_jSFgcXpzTBpdijQw@mail.gmail.com>
 <20170913092511.GA27555@vergenet.net> <CAJ3xEMj1prPRij-Dib96oZMik_k0DzEuXcxi7TbVeSwt9WnDsQ@mail.gmail.com>
 <20170913115931.GG27555@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:45389 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbdIMMiC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 08:38:02 -0400
Received: by mail-oi0-f52.google.com with SMTP id z73so519051oia.2
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 05:38:02 -0700 (PDT)
In-Reply-To: <20170913115931.GG27555@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 13, 2017 at 2:59 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> On Wed, Sep 13, 2017 at 01:03:43PM +0300, Or Gerlitz wrote:
>> On Wed, Sep 13, 2017 at 12:25 PM, Simon Horman
>> <simon.horman@netronome.com> wrote:
>> > On Tue, Sep 12, 2017 at 11:23:55PM +0300, Or Gerlitz wrote:
>> >> On Tue, Sep 12, 2017 at 5:20 PM, Simon Horman
>> >> <simon.horman@netronome.com> wrote:
>> >> > Allow matching on options in tunnel headers.
>> >> > This makes use of existing tunnel metadata support.
>> >>
>> >> Simon,
>> >>
>> >> This patch is about matching on tunnel options, right? but
>> >>
>> >> > Options are a bytestring of up to 256 bytes.
>> >> > Tunnel implementations may support less or more options,
>> >> > or no options at all.
>> >> >
>> >> >  # ip link add name geneve0 type geneve dstport 0 external
>> >> >  # tc qdisc add dev eth0 ingress
>> >> >  # tc qdisc del dev eth0 ingress; tc qdisc add dev eth0 ingress
>> >> >  # tc filter add dev eth0 protocol ip parent ffff: \
>> >> >      flower indev eth0 \
>> >> >         ip_proto udp \
>> >> >         action tunnel_key \
>> >> >             set src_ip 10.0.99.192 \
>> >> >             dst_ip 10.0.99.193 \
>> >> >             dst_port 4789 \
>> >> >             id 11 \
>> >> >             opts 0102800100800022 \
>> >> >     action mirred egress redirect dev geneve0
>> >>
>> >> the example here is on how to use tunnel options in the tunnel set key actions..
>> >>
>> >> And the other way around in the other patch... the patch is about the
>> >> tunnel key set action and the example shows how to match that in
>> >> flower... I guess you want to swap the relevant of the change log.
>> >
>> > Yes, it seems so. Sorry about that.
>>
>> no worries, you can do the swap, but before that
>>
>> >> Anyway, is there any human readable/understandable representation of
>> >> these options? e.g what does 0102800100800022 means for geneve?
>>
>> > Thanks, I had not thought of that. My feeling is that could
>> > be added to the tc tool as follow-up work.
>>
>> could you spend few words on the nature of these options now when we review
>> the kernel patches? I guess this is somehow related to protocols such
>> as geneve and vxlan-gpe  -- it would be good if you elaborate on that
>> a bit, does
>> the kernel does any usage with these options beyond matching on them or stiching
>> them to packet headers?
>
> This feature is to be used in conjunction with tunnels in collect metadata
> (external) mode. As I understand it there are three tunnel netdevs that use
> options metadata in the kernel at this time.
>
> * Geneve
>
>   In the case of Geneve options are TLVs[1]. My reading is that in collect
>   metadata mode the kernel does not appear to do anything other than pass
>   them around as a bytestring.
>
>   [1] https://tools.ietf.org/html/draft-ietf-nvo3-geneve-05#section-3.5
>
> * VXLAN-GBP
>
>   In the case of VXLAN-GBP on RX in collect metadata mode options are used
>   to carry information parsed in vxlan_parse_gbp_hdr() from the VXLAN Group
>   Based Policy Extension[2]. On RX the options data is used to create an
>   extension (header) by vxlan_build_gbp_hdr().
>
>   [2] https://tools.ietf.org/html/draft-smith-vxlan-group-policy-03#section-2.1
>
> * ERSPAN (GRE)
>
>   In the case of ERSPAN, which is a variant of GRE, on RX in collect
>   metadata mode options are used to carry the index parsed from the ERSPAN
>   Type II feature header[3] in erspan_rcv().  The converse is true on TX
>   and is handled by erspan_fb_xmit().
>
>   [3] https://tools.ietf.org/html/draft-foschiano-erspan-03#section-4.2
>
> Users of options:
>
> * There are eBPF hooks to allow getting on and setting tunnel metadata:
>   bpf_skb_set_tunnel_opt, bpf_skb_get_tunnel_opt.
>
> * Open vSwitch is able to match and set Geneve and VXLAN-GBP options.
>
> Neither of the above appear to assume any structure for the data.
>
> I hope the above is the kind of information you are after.

yeah, this helps, do we expect HW offloads to be able to work with
these options? e.g place/match on packets
or even do something beyond that?
