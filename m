From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH v2 net-next 3/4] mlx4: xdp: Reserve headroom for receiving
 packet when XDP prog is active
Date: Tue, 6 Dec 2016 09:42:33 -0800
Message-ID: <5846F889.2010107@gmail.com>
References: <1480821446-4122277-1-git-send-email-kafai@fb.com>
 <1480821446-4122277-4-git-send-email-kafai@fb.com>
 <CALzJLG9Um8ng5JdQihJQ8Y0m+zuTiwnhCZBOqw-WKvLsb0=VCg@mail.gmail.com>
 <20161205195519.GA29784@kafai-mba.local>
 <CALzJLG8-dZAvio7035CM4bFtzGanaLNWA=pExZfBJ6n9-K9ntQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33699 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbcLFRms (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 12:42:48 -0500
Received: by mail-pg0-f68.google.com with SMTP id 3so20488179pgd.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 09:42:48 -0800 (PST)
In-Reply-To: <CALzJLG8-dZAvio7035CM4bFtzGanaLNWA=pExZfBJ6n9-K9ntQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-06 08:50 AM, Saeed Mahameed wrote:
> On Mon, Dec 5, 2016 at 9:55 PM, Martin KaFai Lau <kafai@fb.com> wrote:
>> On Mon, Dec 05, 2016 at 02:54:06AM +0200, Saeed Mahameed wrote:
>>> On Sun, Dec 4, 2016 at 5:17 AM, Martin KaFai Lau <kafai@fb.com> wrote:
>>>> Reserve XDP_PACKET_HEADROOM and honor bpf_xdp_adjust_head()
>>>> when XDP prog is active.  This patch only affects the code
>>>> path when XDP is active.
>>>>
>>>> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
>>>> ---
>>>

[...]

>> FWD:
>> packet received from a port
>> => process by a XDP prog
>> => XDP_TX out to the same port.
>>
>> For example, if the received packet has 1500 payload and the XDP prog
>> encapsulates it in an IPv6 header (+40 bytes).  After testing, it cannot
>> be sent out due to the HW/wire MTU is 1500.
>>
>> Even the wire MTU info was passed to the XDP prog, there is not much a
>> XDP prog could do here other than dropping it.
>>
>> Hence, this patch gives guarantee to the XDP prog such that
>> it can always send out what it has received + XDP_PACKET_HEADROOM.
>>
> 
> Still i am not convinced ! this is against common sense,
> this means that the XDP prog can send packets larger than the  MTU
> seen on netdev!
> 
> anyway if a packet with the size (MTU + XDP_PACKET_HEADROOM) was sent
> from XDP ring and HW allowed it to exit somehow (with the code you
> provided :)), most likely it will be dropped
> at the other end.
> 
> I still think XDP prog should not be allowed to FW packets larger than
> the MTU seen on the netdev and you shouldn't modify the wire MTU just
> for this case.


I agree here it seems changing the MTU arbitrarily from XDP programs
just creates another side effect that can already be handled easily
by explicitly setting the MTU. This complicates the code and risks
confusing users IMO I would prefer to drop this patch and implement
this at the control plane if its really needed. Daniel's iproute xdp
tool could set this for example if its useful.

My $.02 at least.

Thanks,
John
