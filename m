From: "Alex Aizman" <itn780@yahoo.com>
Subject: RE: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Sun, 27 Mar 2005 13:53:54 -0800
Message-ID: <200503272154.j2RLsHp6010460@oss.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <mpm@selenic.com>, <andrea@suse.de>, <michaelc@cs.wisc.edu>,
        <James.Bottomley@HansenPartnership.com>, <netdev@oss.sgi.com>,
        "'David S. Miller'" <davem@davemloft.net>,
        <ksummit-2005-discuss@thunk.org>
To: <open-iscsi@googlegroups.com>
In-Reply-To: 
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alex Aizman wrote:
>
> 1) There are iSCSI connections that should be "protected", 
> resources-wise. Examples: remote swap device, bank accounts 
> database on RAID accessed via iSCSI, etc.
> 
> 2) There are two ways to protect the "protected" connections. 
> One "Big Brother" like way is a centralized Resource Manager 
> that performs a fully deterministic resource accounting 
> throughout the system, all the way from NIC descriptors and 
> on-chip memory up to iSCSI buffers for Data-Out headers. 
> 
> 3) The 2nd way is *awareness* of the "protected" connections 
> propagated throughout the system, along with incremental 
> implementation of more sophisticated recovery schemes.
> 
> 4) The Resource Manager could be used in the following way. 
> At session open time iSCSI control plane calculates iSCSI and 
> TCP resources that should be available at all times. The 
> calculation is done based on: the number of SCSI commands to 
> be processed in parallel (the 'can_queue'), the maximum size 
> of the SCSI payload in the SG, the negotiated maximum number 
> of outstanding R2Ts, sizes of Immediate and FirstBurst data. 
> 
> 5) If Resource manager says there is not enough resources, 
> iSCSI fails session open. This is better than to get in 
> trouble well into runtime.
> 
> 6) For example: to transmit 'can_queue' commands, iSCSI needs 
> N skbufs. Let's say, all can_queue commands transmitted in a burst, 
> and just one of these gets ack-ed by the Target (via 
> StatSN). In the fully deterministic system this does not 
> necessarily mean that the scsi-ml can now send one command - 
> because the full condition involves also recycling of 
> skbuf(s) used for transmitting this one completed command. 
> And although it is hard to imagine that the command gets 
> fully done by the remote target without Tx buffers getting 
> recycled, the theoretical chance exists (e.g., the NIC is 
> slow or the driver has a bad Tx recycling implementation), 
> and the fully deterministic scheme should take it into account.
> 
> 7) Therefore, prior to calling scsi_done() iSCSI asks 
> Resource Manager whether all the TCP etc. resources used for 
> this command are already recycled. 

Just so that it does not look too complicated: there is *no* need to ensure
recycling of exactly *the* recources (skbufs, descriptors, on-board memory)
that were used to transmit the now-completed command. What's needed is to
ensure that the share of resources provisioned at the connection open time
for the transmit side of this (protected) connection is back to (can_queue -
1). 

> If not, the scsi_done() 
> gets postponed. In addition, iSCSI "complains" to Resource 
> Manager that it enters slow path because of this, which could 
> prompt the latter to take an action. (End of the example).
> 
> 8) If we agree to declare some connections 
> "resource-proteced", it would immediately mean that there are 
> possibly other connections that are not (resource-protected). 
> Which in turn gives the Resource Manager a flexibility to 
> OOM-kill those unprotected connections and cannibalize the 
> corresponding resources for the protected ones.
> 
> 9) Without some awareness of the resource-protected 
> connections, and without some kind of resource counting at 
> runtime (let it be partial and incomplete for starters) - the 
> only remaining way for customers that require HA (High 
> Availability) is to over-engineer: use 64GB RAM, TBs of disk 
> space, etc. Which is probably not the end of the world as 
> long as the prices go down..
> 
> Alex
