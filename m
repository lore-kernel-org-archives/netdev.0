From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v10 05/12] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Sun, 24 Jul 2016 22:34:38 +0200
Message-ID: <5795265E.5000704@iogearbox.net>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com> <1468955817-10604-6-git-send-email-bblanco@plumgrid.com> <CALx6S37TR90Af=-n=d0sfxxf_SvtwjRjyf_sds-Ne0UZn9i+AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Tom Herbert <tom@herbertland.com>,
	Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38550 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbcGXUes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2016 16:34:48 -0400
In-Reply-To: <CALx6S37TR90Af=-n=d0sfxxf_SvtwjRjyf_sds-Ne0UZn9i+AA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/2016 06:57 PM, Tom Herbert wrote:
> On Tue, Jul 19, 2016 at 2:16 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
>> Add support for the BPF_PROG_TYPE_XDP hook in mlx4 driver.
>>
>> In tc/socket bpf programs, helpers linearize skb fragments as needed
>> when the program touches the packet data. However, in the pursuit of
>> speed, XDP programs will not be allowed to use these slower functions,
>> especially if it involves allocating an skb.
>>
>> Therefore, disallow MTU settings that would produce a multi-fragment
>> packet that XDP programs would fail to access. Future enhancements could
>> be done to increase the allowable MTU.
>>
>> The xdp program is present as a per-ring data structure, but as of yet
>> it is not possible to set at that granularity through any ndo.
>>
>> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
[...]
>> +       if (prog) {
>> +               prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
>> +               if (IS_ERR(prog))
>> +                       return PTR_ERR(prog);
>> +       }
>> +
>> +       priv->xdp_ring_num = xdp_ring_num;
>> +
>> +       /* This xchg is paired with READ_ONCE in the fast path */
>> +       for (i = 0; i < priv->rx_ring_num; i++) {
>> +               old_prog = xchg(&priv->rx_ring[i]->xdp_prog, prog);
>
> This can be done under a lock instead of relying on xchg.
>
>> +               if (old_prog)
>> +                       bpf_prog_put(old_prog);
>
> I don't see how this can work. Even after setting the new program, the
> old program might still be run (pointer dereferenced before xchg).
> Either rcu needs to be used or the queue should stopped and synced
> before setting the new program.

It's a strict requirement that all BPF programs must run under RCU.
