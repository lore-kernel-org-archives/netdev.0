From: Yan Vugenfirer <yvugenfi@redhat.com>
Subject: Re: [PATCH net V2] vhost: net: switch to use data copy if pending
	DMAs exceed the limit
Date: Mon, 17 Mar 2014 19:20:05 +0200
Message-ID: <B597CA6A-0D2C-4C69-B53C-339E2C8D48F6@redhat.com>
References: <1394170107-12018-1-git-send-email-jasowang@redhat.com>
	<20140310080310.GA754@redhat.com> <53215E22.8020207@redhat.com>
	<5326998A.6060003@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: multipart/mixed; boundary="===============0053611736287108513=="
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Qin Chuanyu <qinchuanyu@huawei.com>, Dmitry Fleytman <dfleytma@redhat.com>
To: Ronen Hod <rhod@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <5326998A.6060003@redhat.com>
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


--===============0053611736287108513==
Content-Type: multipart/alternative; boundary="Apple-Mail=_EEB05D51-5A3C-489C-9443-CAFAF7D644E6"


--Apple-Mail=_EEB05D51-5A3C-489C-9443-CAFAF7D644E6
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii


On Mar 17, 2014, at 8:43 AM, Ronen Hod <rhod@redhat.com> wrote:

> On 03/13/2014 09:28 AM, Jason Wang wrote:
>> On 03/10/2014 04:03 PM, Michael S. Tsirkin wrote:
>>> On Fri, Mar 07, 2014 at 01:28:27PM +0800, Jason Wang wrote:
>>>>> We used to stop the handling of tx when the number of pending DMAs
>>>>> exceeds VHOST_MAX_PEND. This is used to reduce the memory occupation
>>>>> of both host and guest. But it was too aggressive in some cases, since
>>>>> any delay or blocking of a single packet may delay or block the guest
>>>>> transmission. Consider the following setup:
>>>>> 
>>>>>     +-----+        +-----+
>>>>>     | VM1 |        | VM2 |
>>>>>     +--+--+        +--+--+
>>>>>        |              |
>>>>>     +--+--+        +--+--+
>>>>>     | tap0|        | tap1|
>>>>>     +--+--+        +--+--+
>>>>>        |              |
>>>>>     pfifo_fast   htb(10Mbit/s)
>>>>>        |              |
>>>>>     +--+--------------+---+
>>>>>     |     bridge          |
>>>>>     +--+------------------+
>>>>>        |
>>>>>     pfifo_fast
>>>>>        |
>>>>>     +-----+
>>>>>     | eth0|(100Mbit/s)
>>>>>     +-----+
>>>>> 
>>>>> - start two VMs and connect them to a bridge
>>>>> - add an physical card (100Mbit/s) to that bridge
>>>>> - setup htb on tap1 and limit its throughput to 10Mbit/s
>>>>> - run two netperfs in the same time, one is from VM1 to VM2. Another is
>>>>>   from VM1 to an external host through eth0.
>>>>> - result shows that not only the VM1 to VM2 traffic were throttled but
>>>>>   also the VM1 to external host through eth0 is also throttled somehow.
>>>>> 
>>>>> This is because the delay added by htb may lead the delay the finish
>>>>> of DMAs and cause the pending DMAs for tap0 exceeds the limit
>>>>> (VHOST_MAX_PEND). In this case vhost stop handling tx request until
>>>>> htb send some packets. The problem here is all of the packets
>>>>> transmission were blocked even if it does not go to VM2.
>>>>> 
>>>>> We can solve this issue by relaxing it a little bit: switching to use
>>>>> data copy instead of stopping tx when the number of pending DMAs
>>>>> exceed half of the vq size. This is safe because:
>>>>> 
>>>>> - The number of pending DMAs were still limited (half of the vq size)
>>>>> - The out of order completion during mode switch can make sure that
>>>>>   most of the tx buffers were freed in time in guest.
>>>>> 
>>>>> So even if about 50% packets were delayed in zero-copy case, vhost
>>>>> could continue to do the transmission through data copy in this case.
>>>>> 
>>>>> Test result:
>>>>> 
>>>>> Before this patch:
>>>>> VM1 to VM2 throughput is 9.3Mbit/s
>>>>> VM1 to External throughput is 40Mbit/s
>>>>> CPU utilization is 7%
>>>>> 
>>>>> After this patch:
>>>>> VM1 to VM2 throughput is 9.3Mbit/s
>>>>> Vm1 to External throughput is 93Mbit/s
>>>>> CPU utilization is 16%
>>>>> 
>>>>> Completed performance test on 40gbe shows no obvious changes in both
>>>>> throughput and cpu utilization with this patch.
>>>>> 
>>>>> The patch only solve this issue when unlimited sndbuf. We still need a
>>>>> solution for limited sndbuf.
>>>>> 
>>>>> Cc: Michael S. Tsirkin <mst@redhat.com>
>>>>> Cc: Qin Chuanyu <qinchuanyu@huawei.com>
>>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>> I thought hard about this.
>>> Here's what worries me: if there are still head of line
>>> blocking issues lurking in the stack, they will still
>>> hurt guests such as windows which rely on timely
>>> completion of buffers, but it makes it
>>> that much harder to reproduce the problems with
>>> linux guests which don't.
>>> And this will make even it harder to figure out
>>> whether zero copy is actually active to diagnose
>>> high cpu utilization cases.
>> Yes.
>>> 
>>> So I think this is a good trick, but let's make
>>> this path conditional on a new debugging module parameter:
>>> how about head_of_line_blocking with default off?
>> Sure. But the head of line blocking was only partially solved in the
>> patch since we only support in-order completion of zerocopy packets.
>> Maybe we need consider switching to out of order completion even for
>> zerocopy skbs?
> 
> Yan, Dima,
> 
> I remember that there is an issue with out-of-order packets and WHQL.

The test considers out of order packets reception as a failure.

Yan.


> 
> Ronen.
> 
>>> This way if we suspect packets are delayed forever
>>> somewhere, we can enable that and see guest networking block.
>>> 
>>> Additionally, I think we should add a way to count zero copy
>>> and non zero copy packets.
>>> I see two ways to implement this: add tracepoints in vhost-net
>>> or add counters in tun accessible with ethtool.
>>> This can be a patch on top and does not have to block
>>> this one though.
>>> 
>> Yes, I post a RFC about 2 years ago, see
>> https://lkml.org/lkml/2012/4/9/478 which only traces generic vhost
>> behaviours. I can refresh this and add some -net specific tracepoints.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Apple-Mail=_EEB05D51-5A3C-489C-9443-CAFAF7D644E6
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=us-ascii

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html =
charset=3Dus-ascii"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: =
after-white-space;"><br><div><div>On Mar 17, 2014, at 8:43 AM, Ronen Hod =
&lt;<a href=3D"mailto:rhod@redhat.com">rhod@redhat.com</a>&gt; =
wrote:</div><br class=3D"Apple-interchange-newline"><blockquote =
type=3D"cite"><div style=3D"font-size: 12px; font-style: normal; =
font-variant: normal; font-weight: normal; letter-spacing: normal; =
line-height: normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-stroke-width: 0px;">On 03/13/2014 09:28 AM, Jason Wang =
wrote:<br><blockquote type=3D"cite">On 03/10/2014 04:03 PM, Michael S. =
Tsirkin wrote:<br><blockquote type=3D"cite">On Fri, Mar 07, 2014 at =
01:28:27PM +0800, Jason Wang wrote:<br><blockquote =
type=3D"cite"><blockquote type=3D"cite">We used to stop the handling of =
tx when the number of pending DMAs<br>exceeds VHOST_MAX_PEND. This is =
used to reduce the memory occupation<br>of both host and guest. But it =
was too aggressive in some cases, since<br>any delay or blocking of a =
single packet may delay or block the guest<br>transmission. Consider the =
following setup:<br><br>&nbsp;&nbsp;&nbsp;&nbsp;+-----+ =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+-----+<br>&nbsp;&nbsp;&nbsp;&nb=
sp;| VM1 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| VM2 =
|<br>&nbsp;&nbsp;&nbsp;&nbsp;+--+--+ =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+--+--+<br>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;| =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;|<br>&nbsp;&nbsp;&nbsp;&nbsp;+--+--+ =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+--+--+<br>&nbsp;&nbsp;&nbsp;&nb=
sp;| tap0| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| =
tap1|<br>&nbsp;&nbsp;&nbsp;&nbsp;+--+--+ =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+--+--+<br>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;| =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;|<br>&nbsp;&nbsp;&nbsp;&nbsp;pfifo_fast =
&nbsp;&nbsp;htb(10Mbit/s)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;|<br>&nbsp;&nbsp;&nbsp;&nbsp;+--+--------------+---+<br>&nbsp;&nbsp;&n=
bsp;&nbsp;| &nbsp;&nbsp;&nbsp;&nbsp;bridge =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<br>&nbsp;&nbsp;&nb=
sp;&nbsp;+--+------------------+<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;|<br>&nbsp;&nbsp;&nbsp;&nbsp;pfifo_fast<br>&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;|<br>&nbsp;&nbsp;&nbsp;&nbsp;+-----+<br>&nbsp;&nbsp;&nbsp;&=
nbsp;| eth0|(100Mbit/s)<br>&nbsp;&nbsp;&nbsp;&nbsp;+-----+<br><br>- =
start two VMs and connect them to a bridge<br>- add an physical card =
(100Mbit/s) to that bridge<br>- setup htb on tap1 and limit its =
throughput to 10Mbit/s<br>- run two netperfs in the same time, one is =
from VM1 to VM2. Another is<br>&nbsp;&nbsp;from VM1 to an external host =
through eth0.<br>- result shows that not only the VM1 to VM2 traffic =
were throttled but<br>&nbsp;&nbsp;also the VM1 to external host through =
eth0 is also throttled somehow.<br><br>This is because the delay added =
by htb may lead the delay the finish<br>of DMAs and cause the pending =
DMAs for tap0 exceeds the limit<br>(VHOST_MAX_PEND). In this case vhost =
stop handling tx request until<br>htb send some packets. The problem =
here is all of the packets<br>transmission were blocked even if it does =
not go to VM2.<br><br>We can solve this issue by relaxing it a little =
bit: switching to use<br>data copy instead of stopping tx when the =
number of pending DMAs<br>exceed half of the vq size. This is safe =
because:<br><br>- The number of pending DMAs were still limited (half of =
the vq size)<br>- The out of order completion during mode switch can =
make sure that<br>&nbsp;&nbsp;most of the tx buffers were freed in time =
in guest.<br><br>So even if about 50% packets were delayed in zero-copy =
case, vhost<br>could continue to do the transmission through data copy =
in this case.<br><br>Test result:<br><br>Before this patch:<br>VM1 to =
VM2 throughput is 9.3Mbit/s<br>VM1 to External throughput is =
40Mbit/s<br>CPU utilization is 7%<br><br>After this patch:<br>VM1 to VM2 =
throughput is 9.3Mbit/s<br>Vm1 to External throughput is 93Mbit/s<br>CPU =
utilization is 16%<br><br>Completed performance test on 40gbe shows no =
obvious changes in both<br>throughput and cpu utilization with this =
patch.<br><br>The patch only solve this issue when unlimited sndbuf. We =
still need a<br>solution for limited sndbuf.<br><br>Cc: Michael S. =
Tsirkin &lt;<a =
href=3D"mailto:mst@redhat.com">mst@redhat.com</a>&gt;<br>Cc: Qin Chuanyu =
&lt;<a =
href=3D"mailto:qinchuanyu@huawei.com">qinchuanyu@huawei.com</a>&gt;<br>Sig=
ned-off-by: Jason Wang &lt;<a =
href=3D"mailto:jasowang@redhat.com">jasowang@redhat.com</a>&gt;<br></block=
quote></blockquote>I thought hard about this.<br>Here's what worries me: =
if there are still head of line<br>blocking issues lurking in the stack, =
they will still<br>hurt guests such as windows which rely on =
timely<br>completion of buffers, but it makes it<br>that much harder to =
reproduce the problems with<br>linux guests which don't.<br>And this =
will make even it harder to figure out<br>whether zero copy is actually =
active to diagnose<br>high cpu utilization =
cases.<br></blockquote>Yes.<br><blockquote type=3D"cite"><br>So I think =
this is a good trick, but let's make<br>this path conditional on a new =
debugging module parameter:<br>how about head_of_line_blocking with =
default off?<br></blockquote>Sure. But the head of line blocking was =
only partially solved in the<br>patch since we only support in-order =
completion of zerocopy packets.<br>Maybe we need consider switching to =
out of order completion even for<br>zerocopy =
skbs?<br></blockquote><br>Yan, Dima,<br><br>I remember that there is an =
issue with out-of-order packets and =
WHQL.<br></div></blockquote><div><br></div><div>The test considers out =
of order packets reception as a =
failure.</div><div><br></div><div>Yan.</div><div><br></div><br><blockquote=
 type=3D"cite"><div style=3D"font-size: 12px; font-style: normal; =
font-variant: normal; font-weight: normal; letter-spacing: normal; =
line-height: normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-stroke-width: 0px;"><br>Ronen.<br><br><blockquote =
type=3D"cite"><blockquote type=3D"cite">This way if we suspect packets =
are delayed forever<br>somewhere, we can enable that and see guest =
networking block.<br><br>Additionally, I think we should add a way to =
count zero copy<br>and non zero copy packets.<br>I see two ways to =
implement this: add tracepoints in vhost-net<br>or add counters in tun =
accessible with ethtool.<br>This can be a patch on top and does not have =
to block<br>this one though.<br><br></blockquote>Yes, I post a RFC about =
2 years ago, see<br><a =
href=3D"https://lkml.org/lkml/2012/4/9/478">https://lkml.org/lkml/2012/4/9=
/478</a><span class=3D"Apple-converted-space">&nbsp;</span>which only =
traces generic vhost<br>behaviours. I can refresh this and add some -net =
specific tracepoints.<br>--<br>To unsubscribe from this list: send the =
line "unsubscribe netdev" in<br>the body of a message to<span =
class=3D"Apple-converted-space">&nbsp;</span><a =
href=3D"mailto:majordomo@vger.kernel.org">majordomo@vger.kernel.org</a><br=
>More majordomo info at &nbsp;<a =
href=3D"http://vger.kernel.org/majordomo-info.html">http://vger.kernel.org=
/majordomo-info.html</a><br></blockquote><br>--<br>To unsubscribe from =
this list: send the line "unsubscribe kvm" in<br>the body of a message =
to<span class=3D"Apple-converted-space">&nbsp;</span><a =
href=3D"mailto:majordomo@vger.kernel.org">majordomo@vger.kernel.org</a><br=
>More majordomo info at &nbsp;<a =
href=3D"http://vger.kernel.org/majordomo-info.html">http://vger.kernel.org=
/majordomo-info.html</a></div></blockquote></div><br></body></html>=

--Apple-Mail=_EEB05D51-5A3C-489C-9443-CAFAF7D644E6--

--===============0053611736287108513==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============0053611736287108513==--
