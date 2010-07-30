From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] vhost: locking/rcu cleanup
Date: Fri, 30 Jul 2010 16:49:54 +0200
Message-ID: <4C52E692.3070405@kernel.org>
References: <20100729122325.GA24337@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Sridhar Samudrala <samudrala@us.ibm.com>,
	Jeff Dike <jdike@linux.intel.com>,
	Juan Quintela <quintela@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>,
	David Stevens <dlstevens@us.ibm.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100729122325.GA24337@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 07/29/2010 02:23 PM, Michael S. Tsirkin wrote:
> I saw WARN_ON(!list_empty(&dev->work_list)) trigger
> so our custom flush is not as airtight as need be.

Could be but it's also possible that something has queued something
after the last flush?  Is the problem reproducible?

> This patch switches to a simple atomic counter + srcu instead of
> the custom locked queue + flush implementation.
> 
> This will slow down the setup ioctls, which should not matter -
> it's slow path anyway. We use the expedited flush to at least
> make sure it has a sane time bound.
> 
> Works fine for me. I got reports that with many guests,
> work lock is highly contended, and this patch should in theory
> fix this as well - but I haven't tested this yet.

Hmmm... vhost_poll_flush() becomes synchronize_srcu_expedited().  Can
you please explain how it works?  synchronize_srcu_expedited() is an
extremely heavy operation involving scheduling the cpu_stop task on
all cpus.  I'm not quite sure whether doing it from every flush is a
good idea.  Is flush supposed to be a very rare operation?

Having custom implementation is fine too but let's try to implement
something generic if at all possible.

Thanks.

-- 
tejun
