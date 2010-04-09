From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] vhost: Make it more scalable by creating a vhost
	thread per device.
Date: Thu, 08 Apr 2010 17:05:42 -0700
Message-ID: <1270771542.31186.397.camel@w-sridhar.beaverton.ibm.com>
References: <1270229480.13897.8.camel@w-sridhar.beaverton.ibm.com>
	 <1270488911.27874.43.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tom Lendacky <toml@us.ibm.com>, netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1270488911.27874.43.camel@w-sridhar.beaverton.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-04-05 at 10:35 -0700, Sridhar Samudrala wrote:
> On Sun, 2010-04-04 at 14:14 +0300, Michael S. Tsirkin wrote:
> > On Fri, Apr 02, 2010 at 10:31:20AM -0700, Sridhar Samudrala wrote:
> > > Make vhost scalable by creating a separate vhost thread per vhost
> > > device. This provides better scaling across multiple guests and with
> > > multiple interfaces in a guest.
> > 
> > Thanks for looking into this. An alternative approach is
> > to simply replace create_singlethread_workqueue with
> > create_workqueue which would get us a thread per host CPU.
> > 
> > It seems that in theory this should be the optimal approach
> > wrt CPU locality, however, in practice a single thread
> > seems to get better numbers. I have a TODO to investigate this.
> > Could you try looking into this?
> 
> Yes. I tried using create_workqueue(), but the results were not good
> atleast when the number of guest interfaces is less than the number
> of CPUs. I didn't try more than 8 guests.
> Creating a separate thread per guest interface seems to be more
> scalable based on the testing i have done so far.
> 
> I will try some more tests and get some numbers to compare the following
> 3 options.
> - single vhost thread
> - vhost thread per cpu
> - vhost thread per guest virtio interface

Here are the results with netperf TCP_STREAM 64K guest to host on a
8-cpu Nehalem system. It shows cumulative bandwidth in Mbps and host 
CPU utilization.

Current default single vhost thread
-----------------------------------
1 guest:  12500  37%    
2 guests: 12800  46%
3 guests: 12600  47%
4 guests: 12200  47%
5 guests: 12000  47%
6 guests: 11700  47%
7 guests: 11340  47%
8 guests: 11200  48%

vhost thread per cpu
--------------------
1 guest:   4900 25%
2 guests: 10800 49%
3 guests: 17100 67%
4 guests: 20400 84%
5 guests: 21000 90%
6 guests: 22500 92%
7 guests: 23500 96%
8 guests: 24500 99%

vhost thread per guest interface
--------------------------------
1 guest:  12500 37%
2 guests: 21000 72%
3 guests: 21600 79%
4 guests: 21600 85%
5 guests: 22500 89%
6 guests: 22800 94%
7 guests: 24500 98%
8 guests: 26400 99%

Thanks
Sridhar


