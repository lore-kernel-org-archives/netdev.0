From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Thu, 22 Jan 2004 14:50:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFA2457112.0F3CBC9D-ON88256E23.007C851A@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=07BBE4B0DFEF038A8f9e8a93df938690918c07BBE4B0DFEF038A"
Cc: kuznet@ms2.inr.ac.ru, mashirle@us.ibm.com, netdev@oss.sgi.com,
        Shirley Ma <xma@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4B0DFEF038A8f9e8a93df938690918c07BBE4B0DFEF038A
Content-type: multipart/alternative;
	Boundary="1__=07BBE4B0DFEF038A8f9e8a93df938690918c07BBE4B0DFEF038A"

--1__=07BBE4B0DFEF038A8f9e8a93df938690918c07BBE4B0DFEF038A
Content-type: text/plain; charset=US-ASCII





Dave,

Isn't memory barrier used to stop re-ordering of instructions and needs to
be present
in both reader as well as writer to have synchronization since mb is for
the CPU on
which it is executing ? In this case : suppose stat is getting incremented
from
00000000 FFFFFFFF to 00000001 00000000, and stat was read after the low
word was
incremented to 0 (with overflow set), then low1 = 0 and low2 can get
executed before the
low2 is incremented on the other processor, so low2 is still zero. We
return zero, when
the value should be 4G. That why I felt that we need to read second after
making sure
the writer is over, that doesn't assume that writer is faster than reader
and works in all
cases.

Am I wrong here ?

thanks,

- KK



|---------+---------------------------->
|         |           "David S. Miller"|
|         |           <davem@redhat.com|
|         |           >                |
|         |           Sent by:         |
|         |           netdev-bounce@oss|
|         |           .sgi.com         |
|         |                            |
|         |                            |
|         |           01/22/2004 02:10 |
|         |           PM               |
|         |                            |
|---------+---------------------------->
  >-----------------------------------------------------------------------------------------------------------------|
  |                                                                                                                 |
  |       To:       Krishna Kumar/Beaverton/IBM@IBMUS                                                               |
  |       cc:       kuznet@ms2.inr.ac.ru, mashirle@us.ltcfwd.linux.ibm.com, netdev@oss.sgi.com,                     |
  |        netdev-bounce@oss.sgi.com, Shirley Ma/Beaverton/IBM@IBMUS                                                |
  |       Subject:  Re: [PATCH]snmp6 64-bit counter support in proc.c                                               |
  |                                                                                                                 |
  >-----------------------------------------------------------------------------------------------------------------|





The most portable and simple algorithm to solve this on the reader
side is (and I recommend we don't special case this on 64-bit platforms
just to get wider testing):

             u32 high, low1, low2;

             do {
                         low1 = stat & 0xffffffff;
                         rmb();
                         high = stat >> 32;
                         rmb();
                         low2 = stat & 0xffffffff;
             } while (low2 < low1);

Something like that.  The idea is to sample the lower 32-bit twice
and if it overflows resample both high and low halfs.



--1__=07BBE4B0DFEF038A8f9e8a93df938690918c07BBE4B0DFEF038A
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Dave,<br>
<br>
Isn't memory barrier used to stop re-ordering of instructions and needs to be present <br>
in both reader as well as writer to have synchronization since mb is for the CPU on <br>
which it is executing ? In this case : suppose stat is getting incremented from <br>
00000000 FFFFFFFF to 00000001 00000000, and stat was read after the low word was <br>
incremented to 0 (with overflow set), then low1 = 0 and low2 can get executed before the <br>
low2 is incremented on the other processor, so low2 is still zero. We return zero, when <br>
the value should be 4G. That why I felt that we need to read second after making sure <br>
the writer is over, that doesn't assume that writer is faster than reader and works in all <br>
cases.<br>
<br>
Am I wrong here ?<br>
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
</td><td style="background-image:url(cid:10__=07BBE4B0DFEF038A8f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " width="1%"><img src="/icons/ecblank.gif" border="0" height="1" width="225" alt=""><br>

<ul>
<ul>
<ul>
<ul><b><font size="2">&quot;David S. Miller&quot; &lt;davem@redhat.com&gt;</font></b><br>
<font size="2">Sent by: netdev-bounce@oss.sgi.com</font>
<p><font size="2">01/22/2004 02:10 PM</font></ul>
</ul>
</ul>
</ul>
</td><td width="100%"><img src="/icons/ecblank.gif" border="0" height="1" width="1" alt=""><br>
<font size="1" face="Arial">	</font><br>
<font size="2">	To:	</font><font size="2">Krishna Kumar/Beaverton/IBM@IBMUS</font><br>
<font size="2">	cc:	</font><font size="2">kuznet@ms2.inr.ac.ru, mashirle@us.ltcfwd.linux.ibm.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com, Shirley Ma/Beaverton/IBM@IBMUS</font><br>
<font size="2">	Subject:	</font><font size="2">Re: [PATCH]snmp6 64-bit counter support in proc.c</font></td></tr>
</table>
<br>
<br>
<font face="Courier New"><br>
The most portable and simple algorithm to solve this on the reader<br>
side is (and I recommend we don't special case this on 64-bit platforms<br>
just to get wider testing):<br>
<br>
		 u32 high, low1, low2;<br>
<br>
		 do {<br>
		 		 low1 = stat &amp; 0xffffffff;<br>
		 		 rmb();<br>
		 		 high = stat &gt;&gt; 32;<br>
		 		 rmb();<br>
		 		 low2 = stat &amp; 0xffffffff;<br>
		 } while (low2 &lt; low1);<br>
<br>
Something like that.  The idea is to sample the lower 32-bit twice<br>
and if it overflows resample both high and low halfs.<br>
<br>
</font>

</body></html>

--1__=07BBE4B0DFEF038A8f9e8a93df938690918c07BBE4B0DFEF038A--


--0__=07BBE4B0DFEF038A8f9e8a93df938690918c07BBE4B0DFEF038A
Content-type: image/gif;
	name="pic24167.gif"
Content-Disposition: inline; filename="pic24167.gif"
Content-ID: <10__=07BBE4B0DFEF038A8f9e8a93df938@us.ibm.com>
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

--0__=07BBE4B0DFEF038A8f9e8a93df938690918c07BBE4B0DFEF038A--
