From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Wed, 28 Jan 2004 11:19:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFB07FA138.DADDB14B-ON88256E29.00692BAE@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=07BBE4BADFFAAD3E8f9e8a93df938690918c07BBE4BADFFAAD3E"
Cc: kuznet@ms2.inr.ac.ru, mashirle@us.ibm.com, netdev@oss.sgi.com,
        Shirley Ma <xma@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4BADFFAAD3E8f9e8a93df938690918c07BBE4BADFFAAD3E
Content-type: multipart/alternative;
	Boundary="1__=07BBE4BADFFAAD3E8f9e8a93df938690918c07BBE4BADFFAAD3E"

--1__=07BBE4BADFFAAD3E8f9e8a93df938690918c07BBE4BADFFAAD3E
Content-type: text/plain; charset=US-ASCII





Hi Dave,

> We can overflow the lower-half TWICE in the res1=...res2=... sequence
> you do, and this res2 reread in the if branch can overflow itself again,

The snippet assumed that the number will not overflow 4G times twice within
two reads, which I thought was quite a reasonable assumption.

I think a fast and clean solution is using Seq locks, which is how
jiffies_64
is implemented on 32 bit systems. The writers always get the spin lock (can
be per cpu with zero contention/thrashing) and increment the 'seq' number
of
seqlock data struct (all inside write_seqlock), then modify the 64 bit
counter,
and release the lock which increases the 'seq' again. The readers don't get
a lock at all, they just read the 'seq' before and after the reading of the
64 bit
counter, and if it changed, it needs to repeat this cycle of reads. In this
case,
no comparison of high/low order words are also needed. Does that sound
better ?

thanks,

- KK



|---------+---------------------------->
|         |           "David S. Miller"|
|         |           <davem@redhat.com|
|         |           >                |
|         |                            |
|         |           01/28/2004 11:09 |
|         |           AM               |
|         |                            |
|---------+---------------------------->
  >-----------------------------------------------------------------------------------------------------------------|
  |                                                                                                                 |
  |       To:       Krishna Kumar/Beaverton/IBM@IBMUS                                                               |
  |       cc:       kuznet@ms2.inr.ac.ru, mashirle@us.ltcfwd.linux.ibm.com, netdev@oss.sgi.com, Shirley             |
  |        Ma/Beaverton/IBM@IBMUS                                                                                   |
  |       Subject:  Re: [PATCH]snmp6 64-bit counter support in proc.c                                               |
  |                                                                                                                 |
  >-----------------------------------------------------------------------------------------------------------------|




On Thu, 22 Jan 2004 18:45:18 -0800
Krishna Kumar <kumarkr@us.ibm.com> wrote:

>             / * Overflow, sync and re-read, the next read is guaranteed
to
> be greater
>              * than res1.
>              */
>             synchronize_kernel();
>             res2 = *((__u64 *) (((void *) per_cpu_ptr(mib[0], i)) +
sizeof
> (__u64) * nr)));

I don't understand how your scheme can work.

We're trying to detect if the upper 32-bit half of the 64-bit value
belongs with the lower-half.  We can overflow the lower-half TWICE
in the res1=...res2=... sequence you do, and this res2 reread in the if
branch can overflow itself again, combining a lower and upper half which
do not belong to each other.

This is not so trivial to fix, see? :)


--1__=07BBE4BADFFAAD3E8f9e8a93df938690918c07BBE4BADFFAAD3E
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Hi Dave,<br>
<br>
&gt; We can overflow the lower-half TWICE in the res1=...res2=... sequence <br>
&gt; you do, and this res2 reread in the if branch can overflow itself again, <br>
<br>
The snippet assumed that the number will not overflow 4G times twice within <br>
two reads, which I thought was quite a reasonable assumption.<br>
<br>
I think a fast and clean solution is using Seq locks, which is how jiffies_64 <br>
is implemented on 32 bit systems. The writers always get the spin lock (can <br>
be per cpu with zero contention/thrashing) and increment the 'seq' number of <br>
seqlock data struct (all inside write_seqlock), then modify the 64 bit counter, <br>
and release the lock which increases the 'seq' again. The readers don't get <br>
a lock at all, they just read the 'seq' before and after the reading of the 64 bit <br>
counter, and if it changed, it needs to repeat this cycle of reads. In this case, <br>
no comparison of high/low order words are also needed. Does that sound<br>
better ?<br>
<br>
thanks,<br>
<br>
- KK<br>
<br>
<img src="/icons/graycol.gif" width="16" height="16" alt="Inactive hide details for &quot;David S. Miller&quot; &lt;davem@redhat.com&gt;">&quot;David S. Miller&quot; &lt;davem@redhat.com&gt;<br>
<br>
<br>

<table V5DOTBL=true width="100%" border="0" cellspacing="0" cellpadding="0">
<tr valign="top"><td width="1%"><img src="/icons/ecblank.gif" border="0" height="1" width="72" alt=""><br>
</td><td style="background-image:url(cid:10__=07BBE4BADFFAAD3E8f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " width="1%"><img src="/icons/ecblank.gif" border="0" height="1" width="225" alt=""><br>

<ul>
<ul>
<ul>
<ul><b><font size="2">&quot;David S. Miller&quot; &lt;davem@redhat.com&gt;</font></b>
<p><font size="2">01/28/2004 11:09 AM</font></ul>
</ul>
</ul>
</ul>
</td><td width="100%"><img src="/icons/ecblank.gif" border="0" height="1" width="1" alt=""><br>
<font size="1" face="Arial">	</font><br>
<font size="2">	To:	</font><font size="2">Krishna Kumar/Beaverton/IBM@IBMUS</font><br>
<font size="2">	cc:	</font><font size="2">kuznet@ms2.inr.ac.ru, mashirle@us.ltcfwd.linux.ibm.com, netdev@oss.sgi.com, Shirley Ma/Beaverton/IBM@IBMUS</font><br>
<font size="2">	Subject:	</font><font size="2">Re: [PATCH]snmp6 64-bit counter support in proc.c</font></td></tr>
</table>
<br>
<br>
<font face="Courier New">On Thu, 22 Jan 2004 18:45:18 -0800<br>
Krishna Kumar &lt;kumarkr@us.ibm.com&gt; wrote:<br>
<br>
&gt;             / * Overflow, sync and re-read, the next read is guaranteed to<br>
&gt; be greater<br>
&gt;              * than res1.<br>
&gt;              */<br>
&gt;             synchronize_kernel();<br>
&gt;             res2 = *((__u64 *) (((void *) per_cpu_ptr(mib[0], i)) + sizeof<br>
&gt; (__u64) * nr)));<br>
<br>
I don't understand how your scheme can work.<br>
<br>
We're trying to detect if the upper 32-bit half of the 64-bit value<br>
belongs with the lower-half.  We can overflow the lower-half TWICE<br>
in the res1=...res2=... sequence you do, and this res2 reread in the if<br>
branch can overflow itself again, combining a lower and upper half which<br>
do not belong to each other.<br>
<br>
This is not so trivial to fix, see? :)<br>
</font>

</body></html>

--1__=07BBE4BADFFAAD3E8f9e8a93df938690918c07BBE4BADFFAAD3E--


--0__=07BBE4BADFFAAD3E8f9e8a93df938690918c07BBE4BADFFAAD3E
Content-type: image/gif;
	name="pic14735.gif"
Content-Disposition: inline; filename="pic14735.gif"
Content-ID: <10__=07BBE4BADFFAAD3E8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhWABDALP/AAAAAK04Qf79/o+Gm7WuwlNObwoJFCsoSMDAwGFsmIuezf///wAAAAAAAAAA
AAAAACH5BAEAAAgALAAAAABYAEMAQAT/EMlJq704682770RiFMRinqggEUNSHIchG0BCfHhOjAuh
EDeUqTASLCbBhQrhG7xis2j0lssNDopE4jfIJhDaggI8YB1sZeZgLVA9YVCpnGagVjV171aRVrYR
RghXcAGFhoUETwYxcXNyADJ3GlcSKGAwLwllVC1vjIUHBWsFilKQdI8GA5IcpApeJQt8L09lmgkH
LZikoU5wjqcyAMMFrJIDPAKvCFletKSev1HBw8KrxtjZ2tvc3d5VyKtCKW3jfz4uMKmq3xu4N0nK
BVoJQmx2LGVOmrqNjjJf2hHAQo/eDwJGTKhQMcgQEEAnEjFS98+RnW3smGkZU6ncCWav/4wYOnAI
TihRL/4FEwbp28BXMMcoscQCVxlepL4IGDSCyJyVQOu0o7CjmLN50OZlqWmyFy5/6yBBuji0AxFR
M00oQAqNIstqI6qKHUsWRAEAvagsmfUEAImyxgbmUpJk3IklNUtJOUAVLoUr1+wqDGTE4zk+T6FG
uQb3SizBCwatiiUgCBN8vrz+zFjVyQ8FWkOlg4NQiZMB5QS8QO3mpOaKnL0Z2EKvNMSILEThKhCg
zMKPVxYJh23qm9KNW7pArPynMqZDiErsTMqI+LRi3QAgkFUbXpuFKhSYZALd0O5RKa2z9EYKBbpb
qxIKsjUPRgD7I2XYV6wyrOw92ykExP8NW4URhknC5dKGE4v4NENQj2jXjmfNgOZDaXb5glRmXQ33
YEWQYNcZFnrYcIQLNzyTFDQNkXIff0ExVlY4srziQk43inZgL4rwxxINMvpFFAz1KOODHiu+4aEw
NEjFl5B3JIKWKF3k6I9bfUGp5ZZcdunll5IA4cuHvQQJ5gcsoCWOOUwgltIwAKRxJgbIkJAQZEq0
2YliZnpZZ4BH3CnYOXldOUOfQoYDqF1LFHbXCrO8xmRsfoXDXJ6ChjCAH3QlhJcT6VWE6FCkfCco
CgrMFsROrIEX3o2whVjWDjoJccN3LdggSGXLCdLEgHr1lyU3O3QxhgohNKXJCWv8JQr/PDdaqd6w
2rj1inLiGeiCJoDspAoQlYE6QWLSECehcWIYxIQES6zhbn1iImTHEQyqJ4eIxJJoUBc+3CbBuwZE
V5cJPPkIjFDdeEabQbd6WgICTxiiz0f5dBKquXF6k4senwEhYGnKEFJeGrxUZy8dB8gmAXI/sPvH
ESfCwVt5hTgYiqQqtdRNHQIU1PJ33ZqmzgE90OwLaoJcnMop1WiMmgkPHQRIrwgFuNV90A3doNKT
mrKIN07AnGcI9BQjhCBN4RfA1qIZnMqorJCogKfGQnxSCDilTVIA0yl5ciTovgLuBDKFUDE9aQcw
9SA+rjSNf9/M1gxrj6VwDTS0IUSElMzBfsj0NFXR2kwsV1A5IF1grLgLL/r1R40BZEnuBWgmQEyb
jqRwSAt6bqMCOFkvKFN2GPPkUzIm/SCF8z8pVzpbjVnMsy0vOr1hw3SaSRUhpY09v0z0J1FnwzPl
fmh+xl4WtR0zGu24I4KbMQm3lnVu2oNWxI9W/lcyzA+mCKF4DBikxb/+UWtOGRiFP8qEwAayIgIA
Ow==

--0__=07BBE4BADFFAAD3E8f9e8a93df938690918c07BBE4BADFFAAD3E--
