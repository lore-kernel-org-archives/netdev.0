From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 2/2][RFC] virtio_net: Add MAC fitler table support
Date: Fri, 09 Jan 2009 08:34:30 -0700
Message-ID: <1231515270.7109.202.camel@lappy>
References: <1231351563.7109.130.camel@lappy>
	 <1231500852.4481.72.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1231500852.4481.72.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-01-09 at 11:34 +0000, Mark McLoughlin wrote:
> On Wed, 2009-01-07 at 11:06 -0700, Alex Williamson wrote:
> > @@ -38,8 +40,10 @@ struct virtio_net_config
> >  			__u16 link:1;
> >  			__u16 promisc:1;
> >  			__u16 allmulti:1;
> > +			__u16 mac_table:1;
> >  		} bits;
> > -       } status;
> > +	} status;
> > +	__u64 mac_table[16];
> 
> You're using two bytes per entry to indicate the flag is valid. Why
> not
> an array of 6 byte entries with a count of how many entries are valid?
> 
> That would also keep the virtio-net I/O space under 128 bytes.

Thanks for the comments, they look correct.  For the mac_table, that's
exactly how I'm thinking of doing it with virt-queues.  The problem with
that here is that the driver has direct access to the table and doesn't
necessarily have to make it contiguous.  If we expose a table, I think
the more space efficient way is to make the table size a multiple of 8
and have a bitmap of valid entries.

The virt-queue implementation I'm thinking of has 2 interfaces, ALLOC
and SET.  ALLOC can only be called once by the guest driver and
allocates a mac filter table supporting the given number of entries.
The SET interface provides a contiguous list of MACs, fitting into the
size previously allocated.  SET can also be used to clear if called with
no entries.  I'm steering away from a dynamically changeable size as
that implies locking or some kind of linked list implementation, or
both.  Thanks,

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

