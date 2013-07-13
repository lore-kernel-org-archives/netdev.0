From: Dion Kant <g.w.kant@hunenet.nl>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: pull on receive skb may need
 to happen earlier
Date: Sat, 13 Jul 2013 13:26:25 +0200
Message-ID: <51E13961.4030101@hunenet.nl>
References: <8511913.uMAmUdIO30@eistomin.edss.local> <20130517085923.GC14401@zion.uk.xensource.com> <51D57C1F.8070909@hunenet.nl> <20130704150137.GW7483@zion.uk.xensource.com> <51D6AED902000078000E2EA9@nat28.tlf.novell.com> <20130705145319.GB9050@zion.uk.xensource.com> <51DAA9B202000078000E3357@nat28.tlf.novell.com> <51DAE6CA02000078000E3566@nat28.tlf.novell.com> <20130712083248.GF23269@zion.uk.xensource.com> <51DFE0C702000078000E462A@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, davem@davemloft.net,
	xen-devel@lists.xen.org, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: Jan Beulich <JBeulich@suse.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <51DFE0C702000078000E462A@nat28.tlf.novell.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/12/2013 10:56 AM, Jan Beulich wrote:
>>>> On 12.07.13 at 10:32, Wei Liu <wei.liu2@citrix.com> wrote:
>> On Mon, Jul 08, 2013 at 03:20:26PM +0100, Jan Beulich wrote:
>>>>>> On 08.07.13 at 11:59, "Jan Beulich" <JBeulich@suse.com> wrote:
>>>>>>> On 05.07.13 at 16:53, Wei Liu <wei.liu2@citrix.com> wrote:
>>>>> 	skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags;
>>>>> 	skb->len += skb->data_len;
>>>>>     }
>>>>>
>>>>>     handle_incoming_packet();
>>>>>
>>>>> You seem to be altering the behavior of the original code, because in
>>>>> your patch the skb->len is incremented before use, while in the original
>>>>> code (which calls skb_headlen in handle_incoming_packet) the skb->len is
>>>>> correctly set.
>>>>
>>>> Right. So I basically need to keep skb->len up-to-date along with
>>>> ->data_len. Just handed a patch to Dion with that done; I'll defer
>>>> sending a v2 for the upstream code until I know the change works
>>>> for our kernel.
>>>
>>> Okay, so with that done (see below) Dion is now seeing the
>>> WARN_ON_ONCE(delta < len) in skb_try_coalesce() triggering. Of
>>> course, with it having crashed before, it's hard to tell whether the
>>> triggering now is an effect of the patch, or just got unmasked by it.
>>>
>>
>> I just ported your below patch to upstream kernel and I didn't see the
>> WARN_ON_ONCE. I only did iperf and netperf tests.
>>
>> If the work load to trigger this bug is simple enough I can give it a
>> shot...
> 
> I'm meanwhile relatively convinced that the warning isn't an effect
> of the patch (final verification pending); I intend to submit v2 as
> soon as 3.11-rc1 is out.
> 
> Jan
> 

I have been doing some testing and focussed on xennet_fill_frags. I
enhanced a bit the detection of the skb->data_len > nr_frags * PAGE_SIZE
condition (as suggested by Jan) by storing rx->status and nr_frags as
function of each dequeued skb in the while loop.

There is something wrong with the part

+if (nr_frags == MAX_SKB_FRAGS) {
+       unsigned int pull_to = NETFRONT_SKB_CB(skb)->pull_to;
+
+       BUG_ON(pull_to <= skb_headlen(skb));
+       __pskb_pull_tail(skb, pull_to - skb_headlen(skb));
+       nr_frags = shinfo->nr_frags;
+}
+BUG_ON(nr_frags >= MAX_SKB_FRAGS);

When nr_frags reaches MAX_SKB_FRAGS (and this happens), nr_frags is
"reset" to shinfo->nr_frags. In fact I see the nr_frags set to 0 the
first time nr_frags reaches MAX_SKB_FRAGS.

The first problem with this is of course that the "skb->truesize +=
PAGE_SIZE * skb_shinfo(skb)->nr_frags" calculation following the "i =
xennet_fill_frags(np, skb, &tmpq)" in  neif_poll leads to a wrong
result. At the end the skb has ->truesize way smaller than ->len.

The second problem is that the BUG_ON(nr_frags >= MAX_SKB_FRAGS) shall
not occur, since "shinfo->nr_frags" afaict, is not updated in between.

Furthermore, I cannot figure out why, when control enters
xennet_fill_frags(), shinfo->nr_frags equals 1, and a little later when
nr_frags reaches MAX_SKB_FRAGS, it is 0.

Here is the (printk) result of a trial:


>   1 2013-07-13T04:27:30.757241+02:00 doma kernel: [   41.759528] netfront: Too many frags
>   2 2013-07-13T04:27:39.629261+02:00 doma kernel: [   50.628482] 17 == 17 (shinfo->nr_frags=0)
>   3 2013-07-13T04:27:39.629285+02:00 doma kernel: [   50.628486] j=0,rx_trace[j]=48,nr_frags_trace[j]=1
>   4 2013-07-13T04:27:39.629287+02:00 doma kernel: [   50.628488] j=1,rx_trace[j]=1000,nr_frags_trace[j]=2
>   5 2013-07-13T04:27:39.629289+02:00 doma kernel: [   50.628489] j=2,rx_trace[j]=1000,nr_frags_trace[j]=3
>   6 2013-07-13T04:27:39.629291+02:00 doma kernel: [   50.628491] j=3,rx_trace[j]=1000,nr_frags_trace[j]=4
>   7 2013-07-13T04:27:39.629293+02:00 doma kernel: [   50.628492] j=4,rx_trace[j]=1000,nr_frags_trace[j]=5
>   8 2013-07-13T04:27:39.629294+02:00 doma kernel: [   50.628493] j=5,rx_trace[j]=1000,nr_frags_trace[j]=6
>   9 2013-07-13T04:27:39.629296+02:00 doma kernel: [   50.628494] j=6,rx_trace[j]=1000,nr_frags_trace[j]=7
>  10 2013-07-13T04:27:39.629298+02:00 doma kernel: [   50.628496] j=7,rx_trace[j]=1000,nr_frags_trace[j]=8
>  11 2013-07-13T04:27:39.629300+02:00 doma kernel: [   50.628497] j=8,rx_trace[j]=1000,nr_frags_trace[j]=9
>  12 2013-07-13T04:27:39.629302+02:00 doma kernel: [   50.628498] j=9,rx_trace[j]=1000,nr_frags_trace[j]=10
>  13 2013-07-13T04:27:39.629304+02:00 doma kernel: [   50.628499] j=10,rx_trace[j]=1000,nr_frags_trace[j]=11
>  14 2013-07-13T04:27:39.629305+02:00 doma kernel: [   50.628503] j=11,rx_trace[j]=1000,nr_frags_trace[j]=12
>  15 2013-07-13T04:27:39.629307+02:00 doma kernel: [   50.628504] j=12,rx_trace[j]=1000,nr_frags_trace[j]=13
>  16 2013-07-13T04:27:39.629328+02:00 doma kernel: [   50.628506] j=13,rx_trace[j]=1000,nr_frags_trace[j]=14
>  17 2013-07-13T04:27:39.629330+02:00 doma kernel: [   50.628507] j=14,rx_trace[j]=1000,nr_frags_trace[j]=15
>  18 2013-07-13T04:27:39.629332+02:00 doma kernel: [   50.628508] j=15,rx_trace[j]=1000,nr_frags_trace[j]=16
>  19 2013-07-13T04:27:39.629335+02:00 doma kernel: [   50.628510] j=16,rx_trace[j]=e40,nr_frags_trace[j]=0
>  20 2013-07-13T04:27:39.629336+02:00 doma kernel: [   50.628511] xennet::xennet_fill_frags (fe88,feca,500,1,e40,42,42)

line 2 comes from

if (nr_frags == MAX_SKB_FRAGS) {
  unsigned int pull_to = NETFRONT_SKB_CB(skb)->pull_to;

  BUG_ON(pull_to <= skb_headlen(skb));
  __pskb_pull_tail(skb, pull_to - skb_headlen(skb));
+  printk("%u == %lu (shinfo->nr_frags=%u)\n",//temp
+                     nr_frags,MAX_SKB_FRAGS, shinfo->nr_frags);//tmp
  nr_frags = shinfo->nr_frags;
}

Lines 3 to 19 show the dumping I added at the end of the while loop

+if (skb->data_len > nr_frags * PAGE_SIZE) {//tmp
+ for (j=0; j<i; ++j)//tmp
+   printk("j=%u,rx_trace[j]=%x,nr_frags_trace[j]=%u\n", //tmp
+           j,rx_trace[j],nr_frags_trace[j]);//tmp
+ printk("xennet::xennet_fill_frags (%x,%x,%x,%u,%x,%x,%x)\n",//temp
+         skb->data_len, skb->len, skb->truesize, nr_frags,//tmp
+         rx->status, len0, data_len0);//temp
+}

For gathering the data I added a couple of variables on the stack

struct skb_shared_info *shinfo = skb_shinfo(skb);
int nr_frags = shinfo->nr_frags;
RING_IDX cons = np->rx.rsp_cons;
struct sk_buff *nskb;
+unsigned rx_trace[MAX_SKB_FRAGS+1], i=0,j, len0=0, data_len0=0;//tmp
+int nr_frags_trace[MAX_SKB_FRAGS+1];//tmp

and in the while loop

__skb_fill_page_desc(skb, nr_frags,
                     skb_frag_page(skb_shinfo(nskb)->frags),
                     rx->offset, rx->status);

+if (i==0) {//tmp
+  len0=skb->len;//tmp
+  data_len0=skb->data_len;//tmp
+}//tmp

+rx_trace[i] = rx->status;//tmp
skb->len += rx->status;
skb->data_len += rx->status;

skb_shinfo(nskb)->nr_frags = 0;
kfree_skb(nskb);

+nr_frags_trace[i++] = nr_frags;//tmp
nr_frags++;

As a coincidence I noticed that there has to be a subtle condition
related to speed of the while loop required to reach the state where
nr_frags becomes MAX_SKB_FRAGS.

A bit more delay in the while and it does not occur anymore.

E.g. first I had the gathering ordered like

+if (i==0) {//tmp
+  len0=skb->len;//tmp
+  data_len0=skb->data_len;//tmp
+}//tmp

+rx_trace[i] = rx->status;//tmp
+nr_frags_trace[i++] = nr_frags;//tmp
skb->len += rx->status;
skb->data_len += rx->status;

skb_shinfo(nskb)->nr_frags = 0;
kfree_skb(nskb);

nr_frags++;

and I was unable to find nr_frags reaching MAX_SKB_FRAGS within a finite
testing time. I thought this may be worthwhile to share this.

As a workload to trigger this I use simply

dom0-t:~ # scp bigrand.bin doma:/dev/null

and with this on my system the transfer rate settles around 45 MB/s
limited by a saturated core which runs the user land ssh process.

Dion
