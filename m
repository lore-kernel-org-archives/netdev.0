From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Thu, 22 Jan 2004 13:18:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFBED1B971.06995FF1-ON88256E23.006E3E55@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=07BBE4B0DFFDB8C58f9e8a93df938690918c07BBE4B0DFFDB8C5"
Cc: davem@redhat.com (David S. Miller), kuznet@ms2.inr.ac.ru,
        mashirle@us.ibm.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        Shirley Ma <xma@us.ibm.com> (Shirley Ma)
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4B0DFFDB8C58f9e8a93df938690918c07BBE4B0DFFDB8C5
Content-type: multipart/alternative;
	Boundary="1__=07BBE4B0DFFDB8C58f9e8a93df938690918c07BBE4B0DFFDB8C5"

--1__=07BBE4B0DFFDB8C58f9e8a93df938690918c07BBE4B0DFFDB8C5
Content-type: text/plain; charset=US-ASCII





Alexei,

That is a good point you raised, we don't want to read the counter while
the writer
might change and overflow of one word can result in a really corrupt value.

If 64bit counters is a good idea to implement, what I find OK to do is to
penalize the
readers (proc filesystem interface or netlink) but make sure that the
writers don't get
penalized by being forced to serialize, in effect writers must run as fast
as if there were
no other readers. I could think of a hack to make that happen (hopefully
not too ugly :-) :

#if 64_bit_system
the old code is OK here.
#else
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
be greater */
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

The value can reduce only once every 4gig increments, which means that
reading res2 after the first
sync_kernel will be less than res1 very rarely (once a few days on a fast
ethernet card). In case res2
is less than res1, doing another sync_kernel and rereading of res2 is
guaranteed to return a value
greater than res1 because another 4Gig iterations of increments couldn't
happen in the time for one
context switch of all cpus. The sync_kernel is needed so that we don't read
the value faster than the
writer is updating the two words.

Does that sound realistic for implementing 64 bit counters ? Or do you have
better or simpler
suggestions ?

Thanks,

- KK



|---------+---------------------------->
|         |           kuznet@ms2.inr.ac|
|         |           .ru              |
|         |           Sent by:         |
|         |           netdev-bounce@oss|
|         |           .sgi.com         |
|         |                            |
|         |                            |
|         |           01/22/2004 10:26 |
|         |           AM               |
|         |                            |
|---------+---------------------------->
  >-----------------------------------------------------------------------------------------------------------------|
  |                                                                                                                 |
  |       To:       Shirley Ma/Beaverton/IBM@IBMUS                                                                  |
  |       cc:       davem@redhat.com (David S. Miller), mashirle@us.ltcfwd.linux.ibm.com, kuznet@ms2.inr.ac.ru,     |
  |        netdev@oss.sgi.com                                                                                       |
  |       Subject:  Re: [PATCH]snmp6 64-bit counter support in proc.c                                               |
  |                                                                                                                 |
  >-----------------------------------------------------------------------------------------------------------------|




Hello!

> Did you hear different voices?

Here is a little warning. It will give corrupt values on 32 bit archs
when update with 32 bit overflow happens while value is folded.

To do 64 bit arithmetics you need either to serialize reader wrt writer
or to do some funny tricks with detecting overflows while reading and
special sequence of operations at update with proper barriers, which
will be reflected in performance anyway. Essentially, this haemorhoids
is the reason why they stayed 32 bit.

Alexey



--1__=07BBE4B0DFFDB8C58f9e8a93df938690918c07BBE4B0DFFDB8C5
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Alexei,<br>
<br>
That is a good point you raised, we don't want to read the counter while the writer <br>
might change and overflow of one word can result in a really corrupt value.<br>
<br>
If 64bit counters is a good idea to implement, what I find OK to do is to penalize the <br>
readers (proc filesystem interface or netlink) but make sure that the writers don't get<br>
penalized by being forced to serialize, in effect writers must run as fast as if there were<br>
no other readers. I could think of a hack to make that happen (hopefully not too ugly :-) :<br>
<br>
#if 64_bit_system<br>
the old code is OK here.<br>
#else<br>
__u64 get_sync_data(void *mib[], int nr)<br>
{<br>
	__u64 res1, res2;<br>
	__u64 res3;<br>
<br>
	res1 = *((__u64 *) (((void *) per_cpu_ptr(mib[0], i)) + sizeof (__u64) * nr)));<br>
	synchronize_kernel();<br>
	res2 = *((__u64 *) (((void *) per_cpu_ptr(mib[0], i)) + sizeof (__u64) * nr)));<br>
	if (res2 &lt; res1) {<br>
		/ * Overflow, sync and re-read, the next read is guaranteed to be greater */<br>
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
}<br>
<br>
The value can reduce only once every 4gig increments, which means that reading res2 after the first<br>
sync_kernel will be less than res1 very rarely (once a few days on a fast ethernet card). In case res2<br>
is less than res1, doing another sync_kernel and rereading of res2 is guaranteed to return a value <br>
greater than res1 because another 4Gig iterations of increments couldn't happen in the time for one <br>
context switch of all cpus. The sync_kernel is needed so that we don't read the value faster than the<br>
writer is updating the two words.<br>
<br>
Does that sound realistic for implementing 64 bit counters ? Or do you have better or simpler <br>
suggestions ?<br>
<br>
Thanks,<br>
<br>
- KK<br>
<br>
<img src="/icons/graycol.gif" width="16" height="16" alt="Inactive hide details for kuznet@ms2.inr.ac.ru">kuznet@ms2.inr.ac.ru<br>
<br>
<br>

<table V5DOTBL=true width="100%" border="0" cellspacing="0" cellpadding="0">
<tr valign="top"><td width="1%"><img src="/icons/ecblank.gif" border="0" height="1" width="72" alt=""><br>
</td><td style="background-image:url(cid:10__=07BBE4B0DFFDB8C58f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " width="1%"><img src="/icons/ecblank.gif" border="0" height="1" width="225" alt=""><br>

<ul>
<ul>
<ul>
<ul><b><font size="2">kuznet@ms2.inr.ac.ru</font></b><br>
<font size="2">Sent by: netdev-bounce@oss.sgi.com</font>
<p><font size="2">01/22/2004 10:26 AM</font></ul>
</ul>
</ul>
</ul>
</td><td width="100%"><img src="/icons/ecblank.gif" border="0" height="1" width="1" alt=""><br>
<font size="1" face="Arial">	</font><br>
<font size="2">	To:	</font><font size="2">Shirley Ma/Beaverton/IBM@IBMUS</font><br>
<font size="2">	cc:	</font><font size="2">davem@redhat.com (David S. Miller), mashirle@us.ltcfwd.linux.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com</font><br>
<font size="2">	Subject:	</font><font size="2">Re: [PATCH]snmp6 64-bit counter support in proc.c</font></td></tr>
</table>
<br>
<br>
<font face="Courier New">Hello!<br>
<br>
&gt; Did you hear different voices?<br>
<br>
Here is a little warning. It will give corrupt values on 32 bit archs<br>
when update with 32 bit overflow happens while value is folded.<br>
<br>
To do 64 bit arithmetics you need either to serialize reader wrt writer<br>
or to do some funny tricks with detecting overflows while reading and<br>
special sequence of operations at update with proper barriers, which<br>
will be reflected in performance anyway. Essentially, this haemorhoids<br>
is the reason why they stayed 32 bit.<br>
<br>
Alexey<br>
<br>
</font>

</body></html>

--1__=07BBE4B0DFFDB8C58f9e8a93df938690918c07BBE4B0DFFDB8C5--


--0__=07BBE4B0DFFDB8C58f9e8a93df938690918c07BBE4B0DFFDB8C5
Content-type: image/gif;
	name="pic20320.gif"
Content-Disposition: inline; filename="pic20320.gif"
Content-ID: <10__=07BBE4B0DFFDB8C58f9e8a93df938@us.ibm.com>
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

--0__=07BBE4B0DFFDB8C58f9e8a93df938690918c07BBE4B0DFFDB8C5--
