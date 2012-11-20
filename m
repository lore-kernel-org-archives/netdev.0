From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH] xen/netfront: handle compound page
 fragments on transmit
Date: Tue, 20 Nov 2012 15:44:50 +0000
Message-ID: <50ABB38202000078000AA0FD@nat28.tlf.novell.com>
References: <1353403286.18229.159.camel@zakaz.uk.xensource.com>
 <1353411606-15940-1-git-send-email-ian.campbell@citrix.com>
 <50AB856D02000078000A9EFD@nat28.tlf.novell.com>
 <1353418516.13542.38.camel@zakaz.uk.xensource.com>
 <50AB990602000078000A9F5B@nat28.tlf.novell.com>
 <1353420865.13542.44.camel@zakaz.uk.xensource.com>
 <50ABA29902000078000A9FB1@nat28.tlf.novell.com>
 <1353424014.13542.49.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Stefan Bader" <stefan.bader@canonical.com>,
	"Sander Eikelenboom" <linux@eikelenboom.it>,
	"Eric Dumazet" <edumazet@google.com>,
	"KonradRzeszutekWilk" <konrad@kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"ANNIE LI" <annie.li@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ian Campbell" <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:47283 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753142Ab2KTPn4 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:8:1>);
	Tue, 20 Nov 2012 10:43:56 -0500
In-Reply-To: <1353424014.13542.49.camel@zakaz.uk.xensource.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 20.11.12 at 16:06, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> On Tue, 2012-11-20 at 14:32 +0000, Jan Beulich wrote:
>> > @@ -517,15 +540,16 @@ static int xennet_start_xmit(struct sk_buff *skb, 
>> > struct net_device *dev)
>> >  	grant_ref_t ref;
>> >  	unsigned long mfn;
>> >  	int notify;
>> > -	int frags = skb_shinfo(skb)->nr_frags;
>> > +	int slots;
>> >  	unsigned int offset = offset_in_page(data);
>> >  	unsigned int len = skb_headlen(skb);
>> >  	unsigned long flags;
>> >  
>> > -	frags += DIV_ROUND_UP(offset + len, PAGE_SIZE);
>> > -	if (unlikely(frags > MAX_SKB_FRAGS + 1)) {
>> > -		printk(KERN_ALERT "xennet: skb rides the rocket: %d frags\n",
>> > -		       frags);
>> > +	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
>> > +		xennet_count_skb_frag_slots(skb);
>> > +	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
>> 
>> But still - isn't this wrong now (i.e. can't it now validly exceed the
>> boundary checked for)?
> 
> In practice no because of the property that the number of pages backing
> the frags is <= MAX_SKB_FRAGS even if you are using compound pages as
> the frags.

So are you saying that there is something in the system
preventing up to MAX_SKB_FRAGS * SKB_FRAG_PAGE_ORDER
(or NETDEV_FRAG_PAGE_MAX_ORDER) skb-s to be created? I
didn't find any. I do notice that __netdev_alloc_frag() currently
never gets called with a size larger than PAGE_SIZE, but
considering that the function just recently got made capable of
that, I'm sure respective users will show up rather sooner than
later.

Jan
