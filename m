From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ip_fragment:kernel may panic when replay big packet with
 RST flag
Date: Mon, 28 Mar 2011 13:30:23 +0200
Message-ID: <4D90714F.6060408@trash.net>
References: <AANLkTikoSxVd3kTggsCGpjXz-5CFuVNxjnpuZNgWd3eV@mail.gmail.com> <AANLkTimOzYG4Weh7wanYfU_qBM4tJDPz+zJZQx_H-vn0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Feng Gao <kernel.goter@gmail.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimOzYG4Weh7wanYfU_qBM4tJDPz+zJZQx_H-vn0@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26.03.2011 14:36, Changli Gao wrote:
> On Wed, Mar 23, 2011 at 6:49 PM, Feng Gao <kernel.goter@gmail.com> wrote:
>> Hello everyone:
>>
>> PC(A)-linux(B)-PC(C)
>> computer(linux B) with two net interface,eth0 and eth1.
>> PC(A) send syn to PC(C)  though linux B.
>> then PC(C) replay a big packet  with RST flag(use tcpsic or other tools).
>>
>> This RST packet(1480) come in from eth0(mtu 1500) and go out from
>> eth1(mtu 700), so this RST packet should fragment.
>>
>> BUT in tcp_packet func: if the connection has no reply packet,and
>> receive the RST packet.ip_conntrack should  destroy.
>>  if (!test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
>>                /* If only reply is a RST, we can consider ourselves not to
>>                   have an established connection: this is a fairly common
>>                   problem case, so we can delete the conntrack
>>                   immediately.  --RR */
>>                if (th->rst) {
>>                        nf_ct_kill_acct(ct, ctinfo, skb);
>>                        return NF_ACCEPT;
>>                }
>>        }
>>
>> BUT the skb->nfct is not set NULL in func nf_ct_kill_acct.
>> so when this RST packet goto ip_fragment,ip_fragment call nf_copy, in
>> __nf_copy func
>> the fragment skb->nfct point to the destory mem.
>> dst->nfct = src->nfct;
>> nf_conntrack_get(src->nfct);
>>
>> SO finally.kfree_skb call destroy_conntrack again. this may result in
>> LINUX B kernel panic.
>>
> 
> Have you ever tested that? I am afraid no panic will happen.
> nf_ct_kill_acct() just drops the reference owned by the corresponding
> timeout timer to the ct if the timer is installed, so the skb still
> has the reference to the ct after nf_ct_kill_acct() returns. Thanks.

That's correct, the skb's reference is refcounted seperately and
only dropped at the final kfree_skb().
