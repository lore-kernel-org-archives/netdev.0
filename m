From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [Ipoverib] [PATCH] IPv6: Add correct padding
	to IPoIB link addr option
Date: Wed, 19 Jan 2005 13:19:55 +0530
Message-ID: <OF89EA98A0.9BCDAC57-ON87256F8E.00204D4F-65256F8E.002B4CC8@us.ibm.com>
References: <20050119.092018.07351674.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1432503660=="
Cc: ipoverib@ietf.org, davem@davemloft.net,
	openib-general@openib.org, netdev@oss.sgi.com
Return-path: <openib-general-bounces@openib.org>
In-Reply-To: <20050119.092018.07351674.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki / =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

--===============1432503660==
Content-type: multipart/related;
	Boundary="0__=08BBE51DDFB3CBDF8f9e8a93df938690918c08BBE51DDFB3CBDF"

--0__=08BBE51DDFB3CBDF8f9e8a93df938690918c08BBE51DDFB3CBDF
Content-type: multipart/alternative;
	Boundary="1__=08BBE51DDFB3CBDF8f9e8a93df938690918c08BBE51DDFB3CBDF"

--1__=08BBE51DDFB3CBDF8f9e8a93df938690918c08BBE51DDFB3CBDF
Content-type: text/plain; charset=ISO-2022-JP
Content-transfer-encoding: quoted-printable






Hi Roland,

Couple of minor comments on this :

1 : In  "+static int ndisc_addr_option_pad(unsigned short type)", chang=
e
the function
     name to ndisc_lladdr_option_pad() and the argument name to addr_ty=
pe,
to be
     more precise ? addr_option seems confusing, unless it is known tha=
t
this is a LL
     address option (not a big deal, though).

2. I know memset has optimized check for count, but isn't it better to
check for pad
    before this code since most of time it is going to be zero (unless =
you
are doing only
    IB traffic) ?

+           if (pad) {
                  memset(opt + 2, 0, pad);
                  opt   +=3D pad;
                  space -=3D pad;
+           }

3. I guess there is no clean way to avoid changing all consumers of ll_=
addr
to not worry
    about the padding after the length and before the LL address, but i=
t
would be nice if
    that were possible (eg via the ndisc_parse_options).

Also, Dave/Yoshifuji, can't ndisc_options have just nd_opt_array[5] ins=
tead
of nd_opt_array[7],
with indices-1 being used to store/access the options ? In any case, I =
was
expecting 6 rather
than 7 in the current code, since there are 5 options with the array[0]=

being unused.

thanks,

- KK



                                                                       =
    
             YOSHIFUJI Hideaki                                         =
    
             / =1B$B5HF#1QL@=1B(B                                      =
              
             <yoshfuji@linux-i                                         =
 To 
             pv6.org>                  roland@topspin.com,             =
    
             Sent by:                  davem@davemloft.net             =
    
             netdev-bounce@oss                                         =
 cc 
             .sgi.com                  netdev@oss.sgi.com,             =
    
                                       ipoverib@ietf.org,              =
    
                                       openib-general@openib.org       =
    
             01/19/2005 05:50                                      Subj=
ect 
             AM                        Re: [Ipoverib] [PATCH] IPv6: Add=
    
                                       correct padding to IPoIB link ad=
dr  
                                       option                          =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    




David, let me tkink about this.
Thanks.

In article <528y6qej5w.fsf@topspin.com> (at Tue, 18 Jan 2005 09:33:47
-0800), Roland Dreier <roland@topspin.com> says:

> +++ linux-bk/net/ipv6/ndisc.c            2005-01-14 21:20:55.73674509=
1
-0800
> @@ -169,12 +169,33 @@
>
>  #define NDISC_OPT_SPACE(len) (((len)+2+7)&~7)
>
> -static u8 *ndisc_fill_option(u8 *opt, int type, void *data, int
data_len)
> +/*
> + * Return the padding between the option length and the start of the=

> + * link addr.  Currently only IP-over-InfiniBand needs this, althoug=
h
> + * if RFC 3831 IPv6-over-Fibre Channel is ever implemented it may
> + * also need a pad of 2.
> + */
> +static int ndisc_addr_option_pad(unsigned short type)
> +{
> +          switch (type) {
> +          case ARPHRD_INFINIBAND: return 2;
> +          default:                return 0;
> +          }
> +}
> +
> +static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data, int=

data_len,
> +                                                unsigned short
addr_type)
>  {
>            int space =3D NDISC_OPT_SPACE(data_len);
> +          int pad   =3D ndisc_addr_option_pad(addr_type);
>
>            opt[0] =3D type;
>            opt[1] =3D space>>3;
> +
> +          memset(opt + 2, 0, pad);
> +          opt   +=3D pad;
> +          space -=3D pad;
> +
>            memcpy(opt+2, data, data_len);
>            data_len +=3D 2;
>            opt +=3D data_len;

--
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

=

--1__=08BBE51DDFB3CBDF8f9e8a93df938690918c08BBE51DDFB3CBDF
Content-type: text/html; charset=ISO-2022-JP
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>Hi Roland,<br>
<br>
Couple of minor comments on this :<br>
<br>
1 : In <tt>&nbsp;&quot;+static int ndisc_addr_option_pad(unsigned short=
 type)</tt>&quot;, change the function<br>
     name to ndisc_lladdr_option_pad() and the argument name to addr_ty=
pe, to be<br>
     more precise ? addr_option seems confusing, unless it is known tha=
t this is a LL<br>
     address option (not a big deal, though).<br>
<br>
2. I know memset has optimized check for count, but isn't it better to =
check for pad<br>
    before this code since most of time it is going to be zero (unless =
you are doing only<br>
    IB traffic) ?<br>
<br>
+ 		if (pad) {<br>
<tt>			memset(opt + 2, 0, pad);</tt><br>
<tt>			opt &nbsp; +=3D pad;<br>
			space -=3D pad;</tt><br>
<tt>+ 		}</tt><br>
<br>
<tt>3. I guess there is no clean way to avoid changing all consumers of=
 ll_addr to not worry</tt><br>
<tt> &nbsp; &nbsp;about the padding after the length and before the LL =
address, but it would be nice if</tt><br>
<tt> &nbsp; &nbsp;that were possible (eg via the ndisc_parse_options).<=
/tt><br>
<br>
<tt>Also, Dave/Yoshifuji, can't ndisc_options have just nd_opt_array[5]=
 instead of nd_opt_array[7],</tt><br>
<tt>with indices-1 being used to store/access the options ? In any case=
, I was expecting 6 rather</tt><br>
<tt>than 7 in the current code, since there are 5 options with the arra=
y[0] being unused.</tt><br>
<br>
<tt>thanks,</tt><br>
<br>
<tt>- KK</tt><br>
<br>
<img src=3D"cid:10__=3D08BBE51DDFB3CBDF8f9e8a93df938@us.ibm.com" width=3D=
"16" height=3D"16" alt=3D"Inactive hide details for YOSHIFUJI Hideaki /=
 =1B$B5HF#1QL@=1B(B &lt;yoshfuji@linux-ipv6.org&gt;">YOSHIFUJI Hideaki =
/ =1B$B5HF#1QL@=1B(B &lt;yoshfuji@linux-ipv6.org&gt;<br>
<br>
<br>

<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td style=3D"background-image:url(cid:20__=3D08BBE51=
DDFB3CBDF8f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " wid=
th=3D"40%">
<ul>
<ul>
<ul>
<ul><b><font size=3D"2">YOSHIFUJI Hideaki / =1B$B5HF#1QL@=1B(B &lt;yosh=
fuji@linux-ipv6.org&gt;</font></b><font size=3D"2"> </font><br>
<font size=3D"2">Sent by: netdev-bounce@oss.sgi.com</font>
<p><font size=3D"2">01/19/2005 05:50 AM</font></ul>
</ul>
</ul>
</ul>
</td><td width=3D"60%">
<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D08BBE51DDFB3CBDF8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">To</font></div></td><td width=3D"=
100%"><img src=3D"cid:30__=3D08BBE51DDFB3CBDF8f9e8a93df938@us.ibm.com" =
border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">roland@topspin.com, davem@davemloft.net</font></td></t=
r>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D08BBE51DDFB3CBDF8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">cc</font></div></td><td width=3D"=
100%"><img src=3D"cid:30__=3D08BBE51DDFB3CBDF8f9e8a93df938@us.ibm.com" =
border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">netdev@oss.sgi.com, ipoverib@ietf.org, openib-general@=
openib.org</font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D08BBE51DDFB3CBDF8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">Subject</font></div></td><td widt=
h=3D"100%"><img src=3D"cid:30__=3D08BBE51DDFB3CBDF8f9e8a93df938@us.ibm.=
com" border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">Re: [Ipoverib] [PATCH] IPv6: Add correct padding to IP=
oIB link addr option</font></td></tr>
</table>

<table border=3D"0" cellspacing=3D"0" cellpadding=3D"0">
<tr valign=3D"top"><td width=3D"58"><img src=3D"cid:30__=3D08BBE51DDFB3=
CBDF8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"1" width=3D"1" alt=
=3D""></td><td width=3D"336"><img src=3D"cid:30__=3D08BBE51DDFB3CBDF8f9=
e8a93df938@us.ibm.com" border=3D"0" height=3D"1" width=3D"1" alt=3D""><=
/td></tr>
</table>
</td></tr>
</table>
<br>
<tt>David, let me tkink about this.<br>
Thanks.<br>
<br>
In article &lt;528y6qej5w.fsf@topspin.com&gt; (at Tue, 18 Jan 2005 09:3=
3:47 -0800), Roland Dreier &lt;roland@topspin.com&gt; says:<br>
<br>
&gt; +++ linux-bk/net/ipv6/ndisc.c		 2005-01-14 21:20:55.736745091 -080=
0<br>
&gt; @@ -169,12 +169,33 @@<br>
&gt; &nbsp;<br>
&gt; &nbsp;#define NDISC_OPT_SPACE(len) (((len)+2+7)&amp;~7)<br>
&gt; &nbsp;<br>
&gt; -static u8 *ndisc_fill_option(u8 *opt, int type, void *data, int d=
ata_len)<br>
&gt; +/*<br>
&gt; + * Return the padding between the option length and the start of =
the<br>
&gt; + * link addr. &nbsp;Currently only IP-over-InfiniBand needs this,=
 although<br>
&gt; + * if RFC 3831 IPv6-over-Fibre Channel is ever implemented it may=
<br>
&gt; + * also need a pad of 2.<br>
&gt; + */<br>
&gt; +static int ndisc_addr_option_pad(unsigned short type)<br>
&gt; +{<br>
&gt; +		 switch (type) {<br>
&gt; +		 case ARPHRD_INFINIBAND: return 2;<br>
&gt; +		 default: &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbs=
p;return 0;<br>
&gt; +		 }<br>
&gt; +}<br>
&gt; +<br>
&gt; +static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data, =
int data_len,<br>
&gt; +		 		 		 		 &nbsp; unsigned short addr_type)<br>
&gt; &nbsp;{<br>
&gt; &nbsp;		 int space =3D NDISC_OPT_SPACE(data_len);<br>
&gt; +		 int pad &nbsp; =3D ndisc_addr_option_pad(addr_type);<br>
&gt; &nbsp;<br>
&gt; &nbsp;		 opt[0] =3D type;<br>
&gt; &nbsp;		 opt[1] =3D space&gt;&gt;3;<br>
&gt; +<br>
&gt; +		 memset(opt + 2, 0, pad);<br>
&gt; +		 opt &nbsp; +=3D pad;<br>
&gt; +		 space -=3D pad;<br>
&gt; +<br>
&gt; &nbsp;		 memcpy(opt+2, data, data_len);<br>
&gt; &nbsp;		 data_len +=3D 2;<br>
&gt; &nbsp;		 opt +=3D data_len;<br>
<br>
-- <br>
Hideaki YOSHIFUJI @ USAGI Project &lt;yoshfuji@linux-ipv6.org&gt;<br>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF &nbsp;80D8 4807 F894 E062 0EEA<br>
<br>
</tt><br>
</body></html>=


--1__=08BBE51DDFB3CBDF8f9e8a93df938690918c08BBE51DDFB3CBDF--


--0__=08BBE51DDFB3CBDF8f9e8a93df938690918c08BBE51DDFB3CBDF
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <10__=08BBE51DDFB3CBDF8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=08BBE51DDFB3CBDF8f9e8a93df938690918c08BBE51DDFB3CBDF
Content-type: image/gif;
	name="pic32399.gif"
Content-Disposition: inline; filename="pic32399.gif"
Content-ID: <20__=08BBE51DDFB3CBDF8f9e8a93df938@us.ibm.com>
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

--0__=08BBE51DDFB3CBDF8f9e8a93df938690918c08BBE51DDFB3CBDF
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <30__=08BBE51DDFB3CBDF8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=08BBE51DDFB3CBDF8f9e8a93df938690918c08BBE51DDFB3CBDF--


--===============1432503660==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1432503660==--
