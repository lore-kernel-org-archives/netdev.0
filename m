From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [patch-kj] net/ipv4/fib_hash.c: check kmem_cache_create()
Date: Mon, 21 Jun 2004 16:52:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFAE2081FC.04989DF5-ON88256EBA.007184C3@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=07BBE429DFE202538f9e8a93df938690918c07BBE429DFE20253"
Cc: janitor@sternwelten.at, netdev@oss.sgi.com, romieu@fr.zoreil.com,
        "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: maximilian attems <max@stro.at>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE429DFE202538f9e8a93df938690918c07BBE429DFE20253
Content-type: multipart/alternative;
	Boundary="1__=07BBE429DFE202538f9e8a93df938690918c07BBE429DFE20253"

--1__=07BBE429DFE202538f9e8a93df938690918c07BBE429DFE20253
Content-type: text/plain; charset=US-ASCII





> doesn't seem to be enough,
> because if (tb == NULL) fn_hash_kmem won't be freed,
> or am i overseeing something?

Your patch doesn't seem to fix the real problem (and fn_hash_kmem
is not getting leaked, the 'leak' seems intentional to keep using
it even if other allocations in the same routine failed.

The question is should we free all allocated memory and fail the
load since these pointers are used without checking in some ipv4
code (eg fib_lookup) ? Eg. ip_rt_init() return -ENOMEM on memory
failure, but ip_init() doesn't check the value and neither does
inet_init() which calls ip_init(). Should the entire startup
sequence be cleaned up to check return values ? Why continue ipv6
load if some 160 odd bytes are not available on the system ?

(BTW, this code is buggy only if IP_MULTIPLE_TABLES is not defined.)

Thanks,

- KK



|---------+---------------------------->
|         |           maximilian attems|
|         |           <max@stro.at>    |
|         |           Sent by:         |
|         |           netdev-bounce@oss|
|         |           .sgi.com         |
|         |                            |
|         |                            |
|         |           06/21/2004 01:04 |
|         |           PM               |
|         |                            |
|---------+---------------------------->
  >---------------------------------------------------------------------------------------------------------------|
  |                                                                                                               |
  |       To:       "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>                                   |
  |       cc:       romieu@fr.zoreil.com, janitor@sternwelten.at, netdev@oss.sgi.com                              |
  |       Subject:  Re: [patch-kj] net/ipv4/fib_hash.c: check kmem_cache_create()                                 |
  |                                                                                                               |
  >---------------------------------------------------------------------------------------------------------------|




On Tue, 22 Jun 2004, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:

> In article <20040621171832.GE1545@sputnik.stro.at> (at Mon, 21 Jun 2004
19:18:32 +0200), maximilian attems <janitor@sternwelten.at> says:
>
> > From: Francois Romieu <romieu@fr.zoreil.com>
> >
> > kmem_cache_create leak.
> >
> > Note: fib_hash_init() can be called many times.
> >
> > Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
>
> Please tell us what kind of leakage do you see?
> Is it just enough to return NULL if kmem_cache_create() fails
> like this?
>
> --- a/net/ipv4/fib_hash.c          10 Nov 2003 23:40:57 -0000
1.1.1.13
> +++ b/net/ipv4/fib_hash.c          21 Jun 2004 18:19:16 -0000
> @@ -871,12 +871,14 @@
>  {
>            struct fib_table *tb;
>
> -          if (fn_hash_kmem == NULL)
> +          if (fn_hash_kmem == NULL) {
>                        fn_hash_kmem = kmem_cache_create("ip_fib_hash",
>
sizeof(struct fib_node),
>
0, SLAB_HWCACHE_ALIGN,
>
NULL, NULL);
> -
> +                      if (fn_hash_kmem == NULL)
> +                                  return NULL;
> +          }
>            tb = kmalloc(sizeof(struct fib_table) + sizeof(struct
fn_hash), GFP_KERNEL);
>            if (tb == NULL)
>                        return NULL;

doesn't seem to be enough,
because if (tb == NULL) fn_hash_kmem won't be freed,
or am i overseeing something?

a++ maks




--1__=07BBE429DFE202538f9e8a93df938690918c07BBE429DFE20253
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><font face="Courier New">&gt; doesn't seem to be enough,<br>
&gt; because if (tb == NULL) fn_hash_kmem won't be freed, <br>
&gt; or am i overseeing something?</font><br>
<br>
<font face="Courier New">Your patch doesn't seem to fix the real problem (and fn_hash_kmem</font><br>
<font face="Courier New">is not getting leaked, the 'leak' seems intentional to keep using </font><br>
<font face="Courier New">it even if other allocations in the same routine failed.</font><br>
<br>
<font face="Courier New">The question is should we free all allocated memory and fail the </font><br>
<font face="Courier New">load since these pointers are used without checking in some ipv4 </font><br>
<font face="Courier New">code (eg fib_lookup) ? Eg. ip_rt_init() return -ENOMEM on memory </font><br>
<font face="Courier New">failure, but ip_init() doesn't check the value and neither does </font><br>
<font face="Courier New">inet_init() which calls ip_init(). Should the entire startup </font><br>
<font face="Courier New">sequence be cleaned up to check return values ? Why continue ipv6</font><br>
<font face="Courier New">load if some 160 odd bytes are not available on the system ?</font><br>
<br>
<font face="Courier New">(BTW, this code is buggy only if IP_MULTIPLE_TABLES is not defined.)</font><br>
<br>
<font face="Courier New">Thanks,</font><br>
<br>
<font face="Courier New">- KK<br>
</font><br>
<img src="cid:10__=07BBE429DFE202538f9e8a93df938@us.ibm.com" width="16" height="16" alt="Inactive hide details for maximilian attems &lt;max@stro.at&gt;">maximilian attems &lt;max@stro.at&gt;<br>
<br>
<br>

<table V5DOTBL=true width="100%" border="0" cellspacing="0" cellpadding="0">
<tr valign="top"><td width="1%"><img src="cid:20__=07BBE429DFE202538f9e8a93df938@us.ibm.com" border="0" height="1" width="72" alt=""><br>
</td><td style="background-image:url(cid:30__=07BBE429DFE202538f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " width="1%"><img src="cid:20__=07BBE429DFE202538f9e8a93df938@us.ibm.com" border="0" height="1" width="225" alt=""><br>

<ul>
<ul>
<ul>
<ul><b><font size="2">maximilian attems &lt;max@stro.at&gt;</font></b><br>
<font size="2">Sent by: netdev-bounce@oss.sgi.com</font>
<p><font size="2">06/21/2004 01:04 PM</font></ul>
</ul>
</ul>
</ul>
</td><td width="100%"><img src="cid:20__=07BBE429DFE202538f9e8a93df938@us.ibm.com" border="0" height="1" width="1" alt=""><br>
<font size="1" face="Arial">	</font><br>
<font size="2">	To:	</font><font size="2">&quot;YOSHIFUJI Hideaki / ?$B5HF#1QL@&quot; &lt;yoshfuji@linux-ipv6.org&gt;</font><br>
<font size="2">	cc:	</font><font size="2">romieu@fr.zoreil.com, janitor@sternwelten.at, netdev@oss.sgi.com</font><br>
<font size="2">	Subject:	</font><font size="2">Re: [patch-kj] net/ipv4/fib_hash.c: check kmem_cache_create()</font></td></tr>
</table>
<br>
<br>
<font face="Courier New">On Tue, 22 Jun 2004, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:<br>
<br>
&gt; In article &lt;20040621171832.GE1545@sputnik.stro.at&gt; (at Mon, 21 Jun 2004 19:18:32 +0200), maximilian attems &lt;janitor@sternwelten.at&gt; says:<br>
&gt; <br>
&gt; &gt; From: Francois Romieu &lt;romieu@fr.zoreil.com&gt;<br>
&gt; &gt; <br>
&gt; &gt; kmem_cache_create leak.<br>
&gt; &gt; <br>
&gt; &gt; Note: fib_hash_init() can be called many times.<br>
&gt; &gt; <br>
&gt; &gt; Signed-off-by: Maximilian Attems &lt;janitor@sternwelten.at&gt;<br>
&gt; <br>
&gt; Please tell us what kind of leakage do you see?<br>
&gt; Is it just enough to return NULL if kmem_cache_create() fails<br>
&gt; like this?<br>
&gt; <br>
&gt; --- a/net/ipv4/fib_hash.c		 10 Nov 2003 23:40:57 -0000		 1.1.1.13<br>
&gt; +++ b/net/ipv4/fib_hash.c		 21 Jun 2004 18:19:16 -0000<br>
&gt; @@ -871,12 +871,14 @@<br>
&gt;  {<br>
&gt;  		 struct fib_table *tb;<br>
&gt;  <br>
&gt; -		 if (fn_hash_kmem == NULL)<br>
&gt; +		 if (fn_hash_kmem == NULL) {<br>
&gt;  		 		 fn_hash_kmem = kmem_cache_create(&quot;ip_fib_hash&quot;,<br>
&gt;  		 		 		 		 		 		  sizeof(struct fib_node),<br>
&gt;  		 		 		 		 		 		  0, SLAB_HWCACHE_ALIGN,<br>
&gt;  		 		 		 		 		 		  NULL, NULL);<br>
&gt; -<br>
&gt; +		 		 if (fn_hash_kmem == NULL)<br>
&gt; +		 		 		 return NULL;<br>
&gt; +		 }<br>
&gt;  		 tb = kmalloc(sizeof(struct fib_table) + sizeof(struct fn_hash), GFP_KERNEL);<br>
&gt;  		 if (tb == NULL)<br>
&gt;  		 		 return NULL;<br>
<br>
doesn't seem to be enough,<br>
because if (tb == NULL) fn_hash_kmem won't be freed, <br>
or am i overseeing something?<br>
<br>
a++ maks<br>
<br>
<br>
</font>

</body></html>

--1__=07BBE429DFE202538f9e8a93df938690918c07BBE429DFE20253--


--0__=07BBE429DFE202538f9e8a93df938690918c07BBE429DFE20253
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <10__=07BBE429DFE202538f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=07BBE429DFE202538f9e8a93df938690918c07BBE429DFE20253
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <20__=07BBE429DFE202538f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=07BBE429DFE202538f9e8a93df938690918c07BBE429DFE20253
Content-type: image/gif;
	name="pic05285.gif"
Content-Disposition: inline; filename="pic05285.gif"
Content-ID: <30__=07BBE429DFE202538f9e8a93df938@us.ibm.com>
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

--0__=07BBE429DFE202538f9e8a93df938690918c07BBE429DFE20253--
