From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net 1/3] kref: add kref_sub_return
Date: Thu, 13 Feb 2014 16:03:20 -0800
Message-ID: <20140214000320.GC15564@kroah.com>
References: <20140212.190637.328045386111912135.davem@davemloft.net>
	<20140213013902.GA21261@kroah.com>
	<20140212.230506.1305102368255894549.davem@davemloft.net>
	<20140212.230953.770721407102955395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, anatol.pomozov@gmail.com, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, qinchuanyu@huawei.com,
	joern@logfs.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20140212.230953.770721407102955395.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 12, 2014 at 11:09:53PM -0500, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 12 Feb 2014 23:05:06 -0500 (EST)
> 
> > From: Greg KH <gregkh@linuxfoundation.org>
> > Date: Wed, 12 Feb 2014 17:39:02 -0800
> > 
> >> Yes, that's horrible as well, but as was already pointed out in this
> >> thread, you can't rely on that value to really be "1" after reading it
> >> due to the way krefs work, what happened if someone else just grabbed
> >> it?
> >> 
> >> If all they want is a "count" for when to start polling, then use a
> >> separate atomic count, but don't abuse the kref interface for this, I
> >> don't think that will work properly at all.
> > 
> > They want to know which thread of control decrements the count to "1"
> > as buffers are released.
> > 
> > That seems entirely reasonable to me.
> > 
> > They could add another atomic counter for this, but that's rather
> > silly since the kref already has an atomic they can use for this
> > purpose.
> 
> If you still can't understand what they are trying to do, they want to
> do something precisely when the number of pending buffers is dropped
> to 1 or less.
> 
> They are using krefs to track how many buffers are attached at a given
> moment.
> 
> The counter can re-increment after the decrement to 1 or less occurs,
> they don't care.
> 
> But they want precisely the entity that drops it down to 1 or less to
> perform that action.
> 
> Just reading the atomic value directly, they cannot do this.

That makes sense, but is still totally crazy for what a kref was
designed to do.  I'm really wary of giving access to the count of the
kref like this as it will almost always be abused (it's been asked for
before, but not like this.)

So how about just "open coding" a kref for this structure, as it wants
something that doesn't fit into the kref model, and should be pretty
simple to do (you can ensure you get the locking right, unlike almost
all users of krefs, as Al Viro constantly points out to me...)

thanks,

greg k-h
