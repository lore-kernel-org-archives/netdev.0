From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH 2/2] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Tue, 04 Dec 2012 13:17:13 -0500
Message-ID: <338664993.8Hd16PoY2S@sifl>
References: <20121129215724.30020.69464.stgit@sifl> <8577392.82G063LYx2@sifl> <20121204173625.GA13993@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20121204173625.GA13993@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, December 04, 2012 07:36:26 PM Michael S. Tsirkin wrote:
> On Tue, Dec 04, 2012 at 11:18:57AM -0500, Paul Moore wrote:
> > Okay, based on your explanation of TUNSETQUEUE, the steps below are what I
> > believe we need to do ... if you disagree speak up quickly please.
> > 
> > A. TUNSETIFF (new, non-persistent device)
> > 
> > [Allocate and initialize the tun_struct LSM state based on the calling
> > process, use this state to label the TUN socket.]
> > 
> > 1. Call security_tun_dev_create() which authorizes the action.
> > 2. Call security_tun_dev_alloc_security() which allocates the tun_struct
> > LSM blob and SELinux sets some internal blob state to record the label of
> > the calling process.
> > 3. Call security_tun_dev_attach() which sets the label of the TUN socket
> > to match the label stored in the tun_struct LSM blob during A2.  No
> > authorization is done at this point since the socket is new/unlabeled.
> > 
> > B. TUNSETIFF (existing, persistent device)
> > 
> > [Relabel the existing tun_struct LSM state based on the calling process,
> > use this state to label the TUN socket.]
> > 
> > 1. Attempt to relabel/reset the tun_struct LSM blob from the currently
> > stored value, set during A2, to the label of the current calling process.
> > *** THIS IS NOT CURRENTLY DONE IN THE RFC PATCH ***
> > 2. Call security_tun_dev_attach() which sets the label of the TUN socket
> > to match the label stored in the tun_struct LSM blob during B1. No
> > authorization is done at this point since the socket is new/unlabeled.
> > 
> > C. TUNSETQUEUE
> > 
> > [Use the existing tun_struct LSM state to label the new TUN socket.]
> > 
> > 1. Call security_tun_dev_attach() which sets the label of the TUN socket
> > to match the label stored in the tun_struct LSM blob set during either A2
> > or B1. No authorization is done at this point since the socket is
> > new/unlabeled.
>
> Here's what bothers me. libvirt currently opens tun and passes
> fd to qemu. What would prevent qemu from attaching fd using TUNSETQUEUE
> to another device it does not own?

True, assuming all the above is correct and that I'm understanding it 
correctly (Jason?), we should probably add a new SELinux access control for 
TUNSETQUEUE.

The current DAC code exists in tun_not_capable().

-- 
paul moore
security and virtualization @ redhat

