From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC V5 0/5] Multiqueue virtio-net
Date: Mon, 09 Jul 2012 11:23:25 +0800
Message-ID: <4FFA4EAD.7000707@redhat.com>
References: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
	<4FF5D2B7.6080602@hp.com> <4FF696C9.5070907@redhat.com>
	<4FF710FD.2090100@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, mashirle@us.ibm.com,
	kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr,
	davem@davemloft.net, sri@us.ibm.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4FF710FD.2090100@hp.com>
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

On 07/07/2012 12:23 AM, Rick Jones wrote:
> On 07/06/2012 12:42 AM, Jason Wang wrote:
>> I'm not expert of tcp, but looks like the changes are reasonable:
>> - we can do full-sized TSO check in tcp_tso_should_defer() only for
>> westwood, according to tcp westwood
>> - run tcp_tso_should_defer for tso_segs = 1 when tso is enabled.
>
> I'm sure Eric and David will weigh-in on the TCP change.  My initial 
> inclination would have been to say "well, if multiqueue is draining 
> faster, that means ACKs come-back faster, which means the "race" 
> between more data being queued by netperf and ACKs will go more to the 
> ACKs which means the segments being sent will be smaller - as 
> TCP_NODELAY is not set, the Nagle algorithm is in force, which means 
> once there is data outstanding on the connection, no more will be sent 
> until either the outstanding data is ACKed, or there is an 
> accumulation of > MSS worth of data to send.
>
>>> Also, how are you combining the concurrent netperf results?  Are you
>>> taking sums of what netperf reports, or are you gathering statistics
>>> outside of netperf?
>>>
>>
>> The throughput were just sumed from netperf result like what netperf
>> manual suggests. The cpu utilization were measured by mpstat.
>
> Which mechanism to address skew error?  The netperf manual describes 
> more than one:

This mechanism is missed in my test, I would add them to my test scripts.
>
> http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#Using-Netperf-to-Measure-Aggregate-Performance 
>
>
> Personally, my preference these days is to use the "demo mode" method 
> of aggregate results as it can be rather faster than (ab)using the 
> confidence intervals mechanism, which I suspect may not really scale 
> all that well to large numbers of concurrent netperfs.

During my test, the confidence interval would even hard to achieved in 
RR test when I pin vhost/vcpus in the processors, so I didn't use it.
>
> I also tend to use the --enable-burst configure option to allow me to 
> minimize the number of concurrent netperfs in the first place.  Set 
> TCP_NODELAY (the test-specific -D option) and then have several 
> transactions outstanding at one time (test-specific -b option with a 
> number of additional in-flight transactions).
>
> This is expressed in the runemomniaggdemo.sh script:
>
> http://www.netperf.org/svn/netperf2/trunk/doc/examples/runemomniaggdemo.sh 
>
>
> which uses the find_max_burst.sh script:
>
> http://www.netperf.org/svn/netperf2/trunk/doc/examples/find_max_burst.sh
>
> to pick the burst size to use in the concurrent netperfs, the results 
> of which can be post-processed with:
>
> http://www.netperf.org/svn/netperf2/trunk/doc/examples/post_proc.py
>
> The nice feature of using the "demo mode" mechanism is when it is 
> coupled with systems with reasonably synchronized clocks (eg NTP) it 
> can be used for many-to-many testing in addition to one-to-many 
> testing (which cannot be dealt with by the confidence interval method 
> of dealing with skew error)
>

Yes, looks "demo mode" is helpful. I would have a look at these scripts, 
Thanks.
>>> A single instance TCP_RR test would help confirm/refute any
>>> non-trivial change in (effective) path length between the two cases.
>>>
>>
>> Yes, I would test this thanks.
>
> Excellent.
>
> happy benchmarking,
>
> rick jones
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
