From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Thu, 22 Jan 2004 18:45:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF27A95A54.FAB6CE99-ON88256E24.000E2136@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE4B7DF9DA7A68f9e8a93df938690918c07BBE4B7DF9DA7A6"
Cc: kuznet@ms2.inr.ac.ru, mashirle@us.ibm.com, netdev@oss.sgi.com,
        Shirley Ma <xma@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4B7DF9DA7A68f9e8a93df938690918c07BBE4B7DF9DA7A6
Content-type: text/plain; charset=US-ASCII





Hi dave,

> > Do you really care about this situation? It only happens as a race
within
> > one instruction in 4 billion. It will slow everytime if we do this way.

> correctness > performance

> If MRTG hits this case and my net usage graphs have weird spikes
> in them as a result, can I assign the bugzilla entry to you? :-)

If so, do you think the solution that I proposed earlier would work ? No
doubt it is quite ugly to behold :-)
The one issue with it is one extra cache loading in 99.999999999% of cases
(2 instead of 1) and two
extra loading the remaining % of cases, but this is executed rarely and the
user can always wait for
data instead of penalizing the kernel writers. (synchronize_kernel is also
a little heavy, so maybe there
is a more lightweight mechanism to make sure that writer is finished).

thanks,

- KK

__u64 get_sync_data(void *mib[], int nr)
{
      __u64 res1, res2;
      __u64 res3;

      res1 = *((__u64 *) (((void *) per_cpu_ptr(mib[0], i)) + sizeof
(__u64) * nr)));
      synchronize_kernel();
      res2 = *((__u64 *) (((void *) per_cpu_ptr(mib[0], i)) + sizeof
(__u64) * nr)));
      if (res2 < res1) {
            / * Overflow, sync and re-read, the next read is guaranteed to
be greater
             * than res1.
             */
            synchronize_kernel();
            res2 = *((__u64 *) (((void *) per_cpu_ptr(mib[0], i)) + sizeof
(__u64) * nr)));
      }

      /* similar code for mib[1], add both into res3

      return res3;
}
#endif

static __u64
 fold_field(void *mib[], int nr)
{
      ...
      res += get_sync_data(mib, nr);
      ...
}
--0__=07BBE4B7DF9DA7A68f9e8a93df938690918c07BBE4B7DF9DA7A6
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><font face="Courier New">Hi dave,</font><br>
<br>
<font face="Courier New">&gt; &gt; Do you really care about this situation? It only happens as a race within<br>
&gt; &gt; one instruction in 4 billion. It will slow everytime if we do this way.<br>
</font><br>
<font face="Courier New">&gt; correctness &gt; performance<br>
</font><br>
<font face="Courier New">&gt; If MRTG hits this case and my net usage graphs have weird spikes<br>
&gt; in them as a result, can I assign the bugzilla entry to you? :-)</font><br>
<br>
If so, do you think the solution that I proposed earlier would work ? No doubt it is quite ugly to behold :-)<br>
The one issue with it is one extra cache loading in 99.999999999% of cases (2 instead of 1) and two <br>
extra loading the remaining % of cases, but this is executed rarely and the user can always wait for<br>
data instead of penalizing the kernel writers. (synchronize_kernel is also a little heavy, so maybe there <br>
is a more lightweight mechanism to make sure that writer is finished).<br>
<br>
thanks,<br>
<br>
- KK<br>
<br>
__u64 get_sync_data(void *mib[], int nr)<br>
{<br>
	__u64 res1, res2;<br>
	__u64 res3;<br>
<br>
	res1 = *((__u64 *) (((void *) per_cpu_ptr(mib[0], i)) + sizeof (__u64) * nr)));<br>
	synchronize_kernel();<br>
	res2 = *((__u64 *) (((void *) per_cpu_ptr(mib[0], i)) + sizeof (__u64) * nr)));<br>
	if (res2 &lt; res1) {<br>
		/ * Overflow, sync and re-read, the next read is guaranteed to be greater<br>
		 * than res1.<br>
		 */<br>
		synchronize_kernel();<br>
		res2 = *((__u64 *) (((void *) per_cpu_ptr(mib[0], i)) + sizeof (__u64) * nr)));<br>
	}<br>
<br>
	/* similar code for mib[1], add both into res3<br>
<br>
	return res3;<br>
}<br>
#endif<br>
<br>
static __u64 <br>
 fold_field(void *mib[], int nr)<br>
{<br>
	...<br>
	res += get_sync_data(mib, nr);<br>
	...<br>
}
</body></html>
--0__=07BBE4B7DF9DA7A68f9e8a93df938690918c07BBE4B7DF9DA7A6--
