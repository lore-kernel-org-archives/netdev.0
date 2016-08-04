From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC V2 PATCH 17/25] net/netpolicy: introduce
 netpolicy_pick_queue
Date: Thu, 4 Aug 2016 13:21:00 -0700
Message-ID: <57A3A3AC.4010307@gmail.com>
References: <1470339389-8542-1-git-send-email-kan.liang@intel.com>
 <1470339389-8542-18-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mingo@redhat.com, peterz@infradead.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
	daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	jesse.brandeburg@intel.com, andi@firstfloor.org
To: kan.liang@intel.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470339389-8542-18-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-08-04 12:36 PM, kan.liang@intel.com wrote:
> From: Kan Liang <kan.liang@intel.com>
> 
> To achieve better network performance, the key step is to distribute the
> packets to dedicated queues according to policy and system run time
> status.
> 
> This patch provides an interface which can return the proper dedicated
> queue for socket/task. Then the packets of the socket/task will be
> redirect to the dedicated queue for better network performance.
> 
> For selecting the proper queue, currently it uses round-robin algorithm
> to find the available object from the given policy object list. The
> algorithm is good enough for now. But it could be improved by some
> adaptive algorithm later.
> 
> The selected object will be stored in hashtable. So it does not need to
> go through the whole object list every time.
> 
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
>  include/linux/netpolicy.h |   5 ++
>  net/core/netpolicy.c      | 136 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 141 insertions(+)
> 

There is a hook in the tx path now (recently added)

# ifdef CONFIG_NET_EGRESS
        if (static_key_false(&egress_needed)) {
                skb = sch_handle_egress(skb, &rc, dev);
                if (!skb)
                        goto out;
        }
# endif

that allows pushing any policy you like for picking tx queues. It would
be better to use this mechanism. The hook runs 'tc' classifiers so
either write a new ./net/sch/cls_*.c for this or just use ebpf to stick
your policy in at runtime.

I'm out of the office for a few days but when I get pack I can test that
it actually picks the selected queue in all cases I know there was an
issue with some of the drivers using select_queue awhile back.

.John
