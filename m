From: bert hubert <ahu@ds9a.nl>
Subject: Re: Frozen machine with adding a tc filter
Date: Wed, 24 Jul 2002 00:11:42 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020723221142.GA15146@outpost.ds9a.nl>
References: <20020723212803.GA14546@outpost.ds9a.nl> <200207232156.BAA16799@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: albertogli@telpin.COM.AR, netdev@oss.sgi.com, jdike@karaya.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200207232156.BAA16799@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Wed, Jul 24, 2002 at 01:56:22AM +0400, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > However, with the commandlines specified, the classifier returns.. head,
> 
> This is strange. cbq_bind_filter() is supposed to return nil class,
> unless reference has deeper level.

These are the commandlines:

tc qdisc add dev eth0 handle 1:0 root cbq bandwidth 12500000bps avpkt 1000      
tc class add dev eth0 parent 1:0 classid 1:2 cbq bandwidth 12500000bps rate \
	10000bps allot 1500 avpkt 1000 maxburst 5 bounded                              
tc filter add dev eth0 parent 1:0 protocol ip prio 1 handle 1:0:0 u32 \
          divisor 1
tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match u32 \             
	0xd5f4a8d2 0xffffffff at 16 classid 1:0  

In the last command, cbq_bind_filter is called with parent==0:

static unsigned long cbq_bind_filter(struct Qdisc *sch, unsigned long parent,
				     u32 classid)
{
	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
	struct cbq_class *p = (struct cbq_class*)parent;
	struct cbq_class *cl = cbq_class_lookup(q, classid);

	if (cl) {
		if (p && p->level <= cl->level)
			return 0;
		cl->filters++;
		return (unsigned long)cl;
	}
	return 0;
}

cl->level is in fact 1.


Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://www.tk                              the dot in .tk
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
