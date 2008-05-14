From: Jeff Garzik <jeff@garzik.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover,
 performance.
Date: Wed, 14 May 2008 16:37:20 -0400
Message-ID: <482B4D80.5080808@garzik.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <20080514143105.GB14987@shareable.org> <20080514150052.GA15826@2ka.mipt.ru> <482B3899.9070008@garzik.org> <20080514193234.GA10165@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>, Sage Weil <sage@newdream.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080514193234.GA10165@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> No, server to connect is the server, which stores data. By addition it
> will also store it to some other places according to distributed
> algorithm (like weaver, raid, mirror, whatever).
[...]
> Sure the less number of machines between client and storage we have, the
> faster and more robust we are.
> 
> Either client has to write data to all servers, or it has to write it to
> one and wait utill that server will broadcast it further (to quorum or any
> number of machines it wants). Having pure client to think to what
> servers it has to put its data is a bit wrong (if not saying more),
> since it has to join not only data network, but also control one, to
> check that some servers are alive or not, to be able not to race, when
> server is recovering and so on...

Quite true.  It is a trade-off:  additional complexity in the client 
permits reduced latency and increased throughput.  But is the additional 
complexity -- including administrative and access control headaches -- 
worth it?  As you say, the "complex" clients must join the data network.

Hardware manufacturers are putting so much effort into zero-copy and 
RDMA.  The client-to-many approach mimics that trend by minimizing 
latency and data copying (and permitting use of more exotic or unusual 
hardware).

But the client-to-many approach is not as complex as you make out.  A 
key attribute is simply for a client to be able to store new objects and 
metadata on multiple servers in parallel.  Once the data is stored 
redundantly, the metadata controller may take quick action to 
commit/abort the transaction.  You can even shortcut the process further 
by having the replicas send confirmations to the metadata controller.

That said, the biggest distributed systems seem to inevitably grow their 
own "front end server" layer.  Clients connect to N caching/application 
servers, each of which behaves as you describe:  the caching/app server 
connects to the control and data networks, and performs the necessary 
load/store operations.

Personally, I think the most simple thing for _users_ is where 
semi-smart clients open multiple connections to an amorphous cloud of 
servers, where the cloud is self-optimizing, self-balancing, and 
self-repairing internally.

	Jeff



