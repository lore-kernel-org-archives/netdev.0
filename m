From: bert hubert <ahu@ds9a.nl>
Subject: Re: Frozen machine with adding a tc filter
Date: Tue, 23 Jul 2002 23:28:04 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020723212803.GA14546@outpost.ds9a.nl>
References: <20020722212111.GA22916@outpost.ds9a.nl> <200207222257.CAA14506@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: albertogli@telpin.COM.AR, netdev@oss.sgi.com, jdike@karaya.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200207222257.CAA14506@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Tue, Jul 23, 2002 at 02:57:14AM +0400, kuznet@ms2.inr.ac.ru wrote:

> > Please tell me your ideas,
> 
> Well, before all figure out where it deadlocks.

I tried this in User Mode Linux and after some help by Jeff, I figured out
that the deadlock is within cbq_classify() in sch_cbq.c. The problem is that
the 'no upwards classifying' check:

	if (cl == NULL || cl->level >= head->level)
		goto fallback;

is only applied if the classifyer did not return an answer:

	if (!head->filter_list || (result = tc_classify(skb,
		head->filter_list, &res)) < 0)
			goto fallback;

	if ((cl = (void*)res.class) == NULL) {
		if (TC_H_MAJ(res.classid))
			cl = cbq_class_lookup(q, res.classid);
		else if ((cl = defmap[res.classid&TC_PRIO_MAX]) == NULL)
			cl = defmap[TC_PRIO_BESTEFFORT];

		if (cl == NULL || cl->level >= head->level)
			goto fallback;
	}

However, with the commandlines specified, the classifier returns.. head, and
the loop prevention test is never performed.

Suggested fix is to move down the test to the end of the loop so it is
always invoked before iterating. Another test that might sense is to see if
head and cl differ before moving on. A loop is guaranteed in that case.

I can build this into a patch if needed, but I suspect Alexey will want to
write his own.

Thanks for your time.

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://www.tk                              the dot in .tk
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
