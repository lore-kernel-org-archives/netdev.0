From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: Re: rtnl_lock deadlock on 3.10
Date: Mon, 09 Sep 2013 11:48:49 -0500
Message-ID: <522DFBF1.9080509@opengridcomputing.com>
References: <kqul4h$ib8$1@ger.gmane.org> <20130703051152.GA12615@order.stressinduktion.org> <20130703053307.GB12615@order.stressinduktion.org> <20130703172239.GA3439@sbohrermbp13-local.rgmadvisors.com> <51D45EB3.7030404@mellanox.com> <20130715143819.GA3084@sbohrermbp13-local.rgmadvisors.com> <20130729230216.GB4396@sbohrermbp13-local.rgmadvisors.com> <51F7B792.7030803@opengridcomputing.com> <522856A4.8040800@acm.org> <52289FEB.7060606@opengridcomputing.com> <20130906231901.GB10419@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Shawn Bohrer <sbohrer-EgGFQ3RFNTIP7C3xziwOQw@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, swise-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Shawn Bohrer <shawn.bohrer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130906231901.GB10419-/vebjAlq/uFE7V8Yqttd03bhEEblAqRIDbRjUBewulXQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 9/6/2013 6:19 PM, Shawn Bohrer wrote:
> On Thu, Sep 05, 2013 at 10:14:51AM -0500, Steve Wise wrote:
>> Roland, what do you think?
>>
>> As I've said, I think we should go ahead with using the rtnl lock in
>> the core.  Is there a complete patch available for review?  looks
>> like the original was a partial fix.
> I guess I should realize that when no one jumps at fixing my issues
> for me that they probably aren't simple to fix.  The solution that
> Cong proposed was to acquire rtnl_lock() before acquiring the
> infiniband device_mutex, and his partial patch did that in
> ib_register_client().  The problem is that you would also need to do
> that in ib_unregister_client(), ib_register_device(), and
> ib_unregister_device(), and that brings us back to the original
> problem which was that cxgb3 was holding the rtnl_lock() when it
> called ib_register_device().  Thus with the proposed fix I believe
> cxgb3 would already be holding the rtnl_lock() and then call
> ib_register_device() which would try to acquire the rtnl_lock() again
> and deadlock for a different reason.
>
> Actually how does this currently work?  ib_register_device() calls
> client->add() for each client in the list which should call
> ipoib_add_one() which calls register_netdev().  Shouldn't that also
> deadlock in the cxgb3 case?

cxgb3 is an iWARP device and doesn't support IPoIB.

>
> Also while digging through this I think I see another bug which is
> that ipoib_dev_cleanup() can be called from ipoib_add_port() but in
> the current code ipoib_add_port() is not holding the rtnl_lock() which
> appears to be a requirement of ipoib_dev_cleanup().
>
> Sigh...  I'm going to stop looking at this for now and hopefully
> someone can propose a better solution to this issue.

I can help with this, but I'm waiting for Roland to chime in.

Steve.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
