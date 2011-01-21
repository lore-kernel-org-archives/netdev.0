From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Thu, 20 Jan 2011 18:30:14 -0800
Message-ID: <4D38EFB6.8000207@hp.com>
References: <20110110093155.GB13420@verge.net.au>	<20110113064718.GA17905@verge.net.au>	<AANLkTimO=5HmTJO1kmHGAWa-HTac+3d0TbrmJX5W4hVu@mail.gmail.com>	<20110113234135.GC8426@verge.net.au>	<20110114045818.GA29738@redhat.com>	<20110114063528.GB10957@verge.net.au>	<20110114065415.GA30300@redhat.com>	<20110116223728.GA6279@verge.net.au>	<20110117102655.GH23479@redhat.com> <4D35ECE2.4040901@hp.com> <20110120083727.GA1807@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jesse Gross <jesse@nicira.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110120083727.GA1807@verge.net.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Horman wrote:
> [ Trimmed Eric from CC list as vger was complaining that it is too long ]
>...
> I have constructed a test where I run an un-paced  UDP_STREAM test in
> one guest and a paced omni rr test in another guest at the same time.
> Breifly I get the following results from the omni test..
> 
>...
 >
> There is a bit of noise in the results as the two netperf invocations
> aren't started at exactly the same moment
> 
> For reference, my netperf invocations are:
> netperf -c -C -t UDP_STREAM -H 172.17.60.216 -l 12
> netperf.omni -p 12866 -D -c -C -H 172.17.60.216 -t omni -j -v 2 -- -r 1 -d rr -k foo -b 1 -w 200 -m 200

Since the -b and -w are in the test-specific portion, this test was not actually 
  paced. The -w will have been ignored entirely (IIRC) and the -b will have 
attempted to set the "burst" size of a --enable-burst ./configured netperf.  If 
netperf was ./configured that way, it will have had two rr transactions in 
flight at one time - the "regular" one and then the one additional from the -b 
option.  If netperf was not ./configured with --enable-burst then a warning 
message should have been emitted.

Also, I am guessing you wanted TCP_NODELAY set, and that is -D but not a global 
-D.  I'm reasonably confident the -m 200 will have been ignored, but it would be 
best to drop it. So, I think your second line needs to be:

netperf.omni -p 12866 -c -C -H  172.17.60.216 -t omni -j -v 2 -b 1 -w 200 -- -r 
1 -d rr -k foo -D

If you want the request and response sizes to be 200 bytes, use -r 200 
(test-specific).

Also, if you ./configure with --enable-omni first, that netserver will 
understand both omni and non-omni tests at the same time and you don't have to 
have a second netserver on a different control port.  You can also go-in to 
config.h after the ./configure and unset WANT_MIGRATION and then UDP_STREAM in 
netperf will be the "true" classic UDP_STREAM code rather than the migrated to 
omni path.

> foo contains
> PROTOCOL
> THROUGHPUT,THROUGHPUT_UNITS
> LOCAL_SEND_THROUGHPUT
> LOCAL_RECV_THROUGHPUT
> REMOTE_SEND_THROUGHPUT
> REMOTE_RECV_THROUGHPUT
> RT_LATENCY,MIN_LATENCY,MEAN_LATENCY,MAX_LATENCY
> P50_LATENCY,P90_LATENCY,P99_LATENCY,STDDEV_LATENCY
> LOCAL_CPU_UTIL,REMOTE_CPU_UTIL

As the -k file parsing option didn't care until recently (within the hour or 
so), I think it didn't matter that you had more than four lines (assuming that 
is a verbatim cat of foo).  However, if you pull the *current* top of trunk, it 
will probably start to care - I'm in the midst of adding support for "direct 
output selection" in the -k, -o and -O options and also cleaning-up the omni 
printing code to the point where there is only the one routing parsing the 
output selection file.  Currently that is the one for "human" output, which has 
a four line restriction.  I will try to make it smarter as I go.

happy benchmarking,

rick jones
