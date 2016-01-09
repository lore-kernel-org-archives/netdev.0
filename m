From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Fri, 8 Jan 2016 16:17:47 -0800
Message-ID: <CALx6S37pbZCmw+BNowzfmHwfpUKKMABvYs11ka0=314cZPXMSg@mail.gmail.com>
References: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
 <1452171150.8255.207.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>, LKML <linux-kernel@vger.kernel.org>,
 devel@linuxdriverproject.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1452171150.8255.207.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Thu, Jan 7, 2016 at 4:52 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-01-07 at 10:33 +0100, Vitaly Kuznetsov wrote:
>> Recent changes to 'struct flow_keys' (e.g commit d34af823ff40 ("net: Add
>>  VLAN ID to flow_keys")) introduced a performance regression in netvsc
>> driver. Is problem is, however, not the above mentioned commit but the
>> fact that netvsc_set_hash() function did some assumptions on the struct
>> flow_keys data layout and this is wrong. We need to extract the data we
>> need (src/dst addresses and ports) after the dissect.
>>
>> The issue could also be solved in a completely different way: as suggested
>> by Eric instead of our own homegrown netvsc_set_hash() we could use
>> skb_get_hash() which does more or less the same. Unfortunately, the
>> testing done by Simon showed that Hyper-V hosts are not happy with our
>> Jenkins hash, selecting the output queue with the current algorithm based
>> on Toeplitz hash works significantly better.
>
> Were tests done on IPv6 traffic ?
>
> Toeplitz hash takes at least 100 ns to hash 12 bytes (one iteration per
> bit : 96 iterations)
>
> For IPv6 it is 3 times this, since we have to hash 36 bytes.
>
> I do not see how it can compete with skb_get_hash() that directly gives
> skb->hash for local TCP flows.
>
> See commits b73c3d0e4f0e1961e15bec18720e48aabebe2109
> ("net: Save TX flow hash in sock and set in skbuf on xmit")
> and 877d1f6291f8e391237e324be58479a3e3a7407c
> ("net: Set sk_txhash from a random number")
>
> I understand Microsoft loves Toeplitz, but this looks not well placed
> here.
>
+1

We need a little more of an explanation on why "Toeplitz hash works
significantly better" than Jenkins hash. We already know that Toeplitz
is expensive to do in SW and there has been some proposals to optimize
it which don't seem to have been applied to hv_netvsc (I believe Eric
had a good implementation). Assuming skb_get_hash isn't sufficient the
Toeplitz hash should be in a common library anyway, we really don't
want drivers or modules inventing new ways to hash packets this point!

Tom

> I suspect there is another problem.
>
> Please share your numbers and test methodology, and the alternative
> patch Simon tested so that we can double check it.
>
> Thanks.
>
> PS: For the time being this patch can probably be applied on -net tree,
> as it fixes a real bug.
>
>
>
