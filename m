From: jamal <hadi@cyberus.ca>
Subject: Re: netif_rx packet dumping
Date: 08 Mar 2005 17:02:01 -0500
Message-ID: <1110319320.1078.97.camel@jzny.localdomain>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	 <20050303125556.6850cfe5.davem@davemloft.net>
	 <1109884688.1090.282.camel@jzny.localdomain>
	 <20050303132143.7eef517c@dxpl.pdx.osdl.net>
	 <1109885065.1098.285.camel@jzny.localdomain>
	 <20050303133237.5d64578f.davem@davemloft.net>
	 <20050303135416.0d6e7708@dxpl.pdx.osdl.net>
	 <Pine.LNX.4.58.0503031657300.22311@tesla.psc.edu>
	 <1109888811.1092.352.camel@jzny.localdomain>
	 <20050303151606.3587394f@dxpl.pdx.osdl.net>  <4227A23C.5050300@ev-en.org>
	 <1109907956.1092.476.camel@jzny.localdomain>  <42282098.8010506@ev-en.org>
	 <1110203711.1088.1393.camel@jzny.localdomain>  <422DCB14.1040805@ev-en.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-6YeoS9RYbwAs2WPMZJ1Y"
Cc: Stephen Hemminger <shemminger@osdl.org>, John Heffner <jheffner@psc.edu>,
        "David S. Miller" <davem@davemloft.net>, rhee@eos.ncsu.edu,
        Yee-Ting.Li@nuim.ie, netdev@oss.sgi.com
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <422DCB14.1040805@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-6YeoS9RYbwAs2WPMZJ1Y
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2005-03-08 at 10:56, Baruch Even wrote:
> jamal wrote:
> > 
> > Were the processors tied to NICs? 
> 
> No. These are single CPU machines (with HT).
> 

You have SMP.

> > In other words the whole queue was infact dedicated just for your one
> > flow - thats why you can call this queue a transient burst queue. 
> 
> Indeed, For a router or a web server handling several thousand flows it 
> might be different, but I don't expect it handles a single packet in one 
> ms (or more) as it happens for the current end-system ack handling code.
> 

I think it would be interesting as well to see more than one flow;
maybe go upto 16 (1, 2, 4, 8, 16) and if theres anything to observe you
should see it.

> > Do you still have the data that shows how many packets were dropped
> > during this period. Do you still have the experimental data? I am
> > particulary interested in seeing the softnet stats as well as tcp
> > netstats.
> 
> No, These tests were not run by me, I'll probably rerun similar tests as 
> well to base my work on, send me in private how do I get the stats from 
> the kernel and I'll add it to my test scripts.
> 

I will be more than happy to help. Let me know when you are ready.

> > I think your main problem was the huge amounts of SACK on the writequeue
> > and the resultant processing i.e section 1.1 and how you resolved that.
> 
> That is my main guess as well, the original work was done rather 
> quickly, we are now reorganizing thoughts and redoing the tests in a 
> more orderly fashion.
> 

I have attached the little patch i forgot to last time where you can
adjust. Adjust the lo_cong parameter in /proc to tune the number of
packets in which the congestion valve gets opened. Make sure you 
are within range of the other parameters like no_cong etc.
Or you can change that check to be using no_cong instead.

> > I dont see any issue in dropping ACKs, many of them even for such large
> > windows as you have - TCPs ACKs are cummulative. It is true if you drop
> > "large" enough amounts of ACKS, you will end up in timeouts - but large
> > enough in your case must be in the minimal 1000 packets. And to say you
> > dropped a 1000 packets while processing 300 means you were taking too
> > long processing the 300.
> 
> With the current code SACK processing takes a long time, so it is 
> possible that it happened to drop more than a thousand packets while 
> handling 300. I think that after the fixing of the SACK code, the rest 
> might work without getting to much into the ingress queue. But that 
> might still change when we go to even higher speeds.
> 

Sure. I am not questioning fixing the SACK code - I dont think it was
envisioned that someone was going to have 1000 outstanding SACKs in 
_one_ flow.  But an interesting test case would be to fix the SACK
processing then retest without getting rid of the congestion valve.
Again, shall i repeat you really should be using NAPI? ;->

> > Then what would be really interesting is to see the perfomance you get
> > from multiple flows with and without congestion.
> 
> We'd need to get a very high speed link for multiple high speed flows.
> 

Get a couple of PCs and hook them back to back.

> > I am not against a the benchmarky nature of the single flow and tuning
> > for that, but we should also look at a wider scope at the effect before
> > you handwave based on the result of one testcase.
> 
> I can't say I didn't handwave, but then, there is little experimentation 
> done to see if the other claims are correct and that AFQ is really 
> needed so early in the packet receive stage. There are also voices that 
> say AFQ sucks and causes more damage than good, I don't remember details 
> currently.
> 

Its not totaly AFQ,
The idea is that code is measuring (based on history) how busy the
system is. What Stephen and I were discussing is that you may wanna
totaly punish new flows coming in instead of the one flow that already
is flowing when the going gets tough (i.e congestion detected). However,
this maybe too big unneeded a hack when we have NAPI which will do just
fine for you.

> > So if i was you i would repeat 1.2 with the fix from 1.1 as well as
> > tying the NIC to one CPU. And it would be a good idea to present more
> > detailed results - not just tcp windows fluctuating (you may not need
> > them for the paper, but would be useful to see for debugging purposes
> > other parameters).
> 
> I'd be happy to hear what other benchmarks you would like to see, I 
> currently intend to add some ack processing time analysis and oprofile 
> information. With possibly showing the size of the ingress queue as a 
> measure as well.
> 
> Making it as thorough as possible is one of my goals. Input is always 
> welcome.
> 

Good - and thanks for not being defensive; your work can only get better
this way. Ping me when you have ported to 2.6.11 and are ready to do the
testing.

cheers,
jamal

--=-6YeoS9RYbwAs2WPMZJ1Y
Content-Disposition: attachment; filename=cong_p
Content-Type: text/plain; name=cong_p; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- 2611-mod/net/core/dev.c	2005/03/07 12:26:21	1.1
+++ 2611-mod/net/core/dev.c	2005/03/07 12:30:19
@@ -1742,6 +1742,9 @@
 		if (work >= quota || jiffies - start_time > 1)
 			break;
 
+		if (queue->throttle && work >= lo_cong)
+			queue->throttle = 0;
+
 	}
 
 	backlog_dev->quota -= work;

--=-6YeoS9RYbwAs2WPMZJ1Y--
