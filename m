From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Tue, 18 Jan 2011 13:28:58 -0800
Message-ID: <4D36061A.5060108@hp.com>
References: <20110110093155.GB13420@verge.net.au>	<20110113064718.GA17905@verge.net.au>	<AANLkTimO=5HmTJO1kmHGAWa-HTac+3d0TbrmJX5W4hVu@mail.gmail.com>	<20110113234135.GC8426@verge.net.au>	<20110114045818.GA29738@redhat.com>	<20110114063528.GB10957@verge.net.au>	<20110114065415.GA30300@redhat.com>	<20110116223728.GA6279@verge.net.au>	<20110117102655.GH23479@redhat.com> <4D35ECE2.4040901@hp.com> <20110118201333.GD18760@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>, Jesse Gross <jesse@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110118201333.GD18760@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael S. Tsirkin wrote:
> On Tue, Jan 18, 2011 at 11:41:22AM -0800, Rick Jones wrote:
> 
>>PS - the enhanced latency statistics from -j are only available in
>>the "omni" version of the TCP_RR test.  To get that add a
>>--enable-omni to the ./configure - and in this case both netperf and
>>netserver have to be recompiled.
> 
> Is this TCP only? I would love to get latency data from UDP as well.

I believe it will work with UDP request response as well.  The omni test code 
strives to be protocol agnostic.  (I'm sure there are bugs of course, there 
always are.)

There is though the added complication of there being no specific matching of 
requests to responses.  The code as written takes advantage of TCP's in-order 
semantics and recovery from packet loss.  In a "plain" UDP_RR test, with one at 
a time transactions, if either the request or response are lost, data flow 
effectively stops there until the timer expires.  So, one has "reasonable" RTT 
numbers from before that point.  In a burst UDP RR test, the code doesn't know 
which request/response was lost and so the matching being done to get RTTs will 
be off by each lost datagram.  And if something were re-ordered the timstamps 
would be off even without a datagram loss event.

To "fix" that would require netperf do something it has not yet done in 18-odd 
years :)  That is actually echo something back from the netserver on the RR test 
- either an id, or a timestamp.  That means "dirtying" the buffers which means 
still more cache misses, from places other than the actual stack. Not beyond the 
realm of the possible, but it would be a bit of departure for "normal" operation 
(*) and could enforce a minimum request/response size beyond the present single 
byte (ok, perhaps only two or four bytes :).  But that, perhaps, is a discussion 
best left to netperf-talk at netperf.org.

happy benchmarking,

rick jones

(*) netperf does have the concept of reading from and/or dirtying buffers, 
put-in back in the days of COW/page-remapping in HP-UX 9.0, but that was mainly 
to force COW and/or show the effect of the required data cache purges/flushes. 
As such it was made conditional on DIRTY being defined.
