From: Ben Greear <greearb@candelatech.com>
Subject: Re: NAPI:  dev.c change to net_rx_action algorithm.
Date: Fri, 08 Nov 2002 21:30:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DCC9D7D.6020005@candelatech.com>
References: <Pine.GSO.4.30.0211082351540.16986-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> On Fri, 8 Nov 2002, Ben Greear wrote: 
>>I'm looking for the real cause.
> No you are not. You are looking for something that will give you some
> quick fix given your current setup.

Guilty, and as soon as I get this particular config optomized, I will
move on to the next scenario.  If the next scenario is better by some
other hack, then I will figure out how to reconcile the two, or make
the algorithms dynamic if I have to.

> Be systematic about and prove where things are wrong. I even made some
> suggestions to you a while back.

Things are wrong:  I can't tx and rx 8kpps (50Mbps) on 4 ports simultaneously.
I have fiddled with every magic static constant I could find, so now I'm
fidling with algoritms.  Primary culprit is rx-drop, which means the NIC
is not getting serviced in time, if I understand correctly.  I have 1024
rx-ring, which most agree is too large already, and yet it fills before
I can empty it.

Btw, and you'll love this one, if I change the priority of the irq thread
to -18, things get even better ;)

>> From what I can tell, the old code punishes interfaces who are
>>running slower at any given time.
> 
> 
> You are totaly wrong. Go and read the paper on DRR.

I read the code.  It's likely I'm confused, but here is how
I interpret it.

#  If we are out of quota, refill quota but do not poll.
#    Why shouldn't we poll here?  We wouldn't be in this list
#    If there was nothing to poll, eh?

#  If we have quota, poll, but only refill quota if we still have
#  more work to do.  Busy devices have more work to do.  Slow ones
#  will not.  So, slow devices will have < dev->weight quota much of
#  the time.  If the formerly slow device suddenly gets a large burst of
#  traffic, it's first poll will likely be for a quota smaller than
#  dev->weight.  Why would this be good?

#  If we have quota, but do not not have more work to do after polling,
#  then pop out of the queue.  Note quota is not refilled in this case,
#  again punishing devices that are running slower.

		if (dev->quota <= 0 || dev->poll(dev, &budget)) {
			local_irq_disable();
			list_del(&dev->poll_list);
			list_add_tail(&dev->poll_list, &queue->poll_list);
			if (dev->quota < 0)
                                 dev->quota += dev->weight;
                         else
                                 dev->quota = dev->weight;
		} else {
			dev_put(dev);
			local_irq_disable();
		}

>>I see better results with the change below.  Why is that?
>>
> 
> 
> You tell me.

I think my algorithm is better, at least for this case.  It may
be worse for others, though I'm not sure why it would be.  The
one thing you can be certain of is that I'll let you know if
I figure it out :)

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
