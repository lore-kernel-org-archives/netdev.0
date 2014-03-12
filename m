From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: Re: [PATCH RFC] netfilter: cacheline aligning in struct netns_ct
Date: Wed, 12 Mar 2014 20:20:21 +0800
Message-ID: <CAABZP2yJFaWN1OKs0ax-4TCYjo5hi+N6JBq7RAdM89mG_cdphQ@mail.gmail.com>
References: <1394610994-22794-1-git-send-email-yizhouzhou@ict.ac.cn>
	<063D6719AE5E284EB5DD2968C1650D6D0F6DB542@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"jbenc@redhat.com" <jbenc@redhat.com>,
	"brouer@redhat.com" <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6DB542@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Jesper and David for reviewing and replying.

Great commitment of Jesper for moving above three hlist_nulls_heads to
percpu structure. Sorry to miss the newest advances in nf-next.

And arbitrarily cache-line aligning structure members is not a good idea
for large cache lines.

Still I have an idea that could we pack the seldom changed members
 (nf_ct_proto included) to a structure and we allocated it from a
cache aligned slub when the structure "net" is initialized.


Zhouyi

On Wed, Mar 12, 2014 at 5:36 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Zhouyi Zhou
>> not frequently changing components should share same cachelines
>>
>> Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
>> ---
>>  include/net/netns/conntrack.h |   12 ++++++++----
>>  1 file changed, 8 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
>> index fbcc7fa..69d2d58 100644
>> --- a/include/net/netns/conntrack.h
>> +++ b/include/net/netns/conntrack.h
>> @@ -65,6 +65,12 @@ struct nf_ip_net {
>>  struct netns_ct {
>>       atomic_t                count;
>>       unsigned int            expect_count;
>> +     struct hlist_nulls_head unconfirmed;
>> +     struct hlist_nulls_head dying;
>> +     struct hlist_nulls_head tmpl;
>> +
>> +     /*  not frequently changing components should share same cachelines */
>> +     struct nf_ip_net        nf_ct_proto ____cacheline_aligned_in_smp;
>
> I'm not sure this has the effect you are trying to achieve.
> Adding an __attribute__((aligned(n))) to a structure member not only
> adds padding before the member, but also pads the member to a multiple
> of the specified size.
>
> With large cache lines you probably want neither.
> IIRC one of the ppc systems has something like 256 byte cache lines
> (and if it doesn't now, it might have soon).
> So arbitrarily cache-line aligning structure members may not be a good idea.
>
> In any case reducing the number of cache lines accessed, and the number
> dirtied is probably more important than putting 'readonly' data in its
> own cache lines.
>
>         David
>
>
>
