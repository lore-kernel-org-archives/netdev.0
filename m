From: "Brian Braunstein" <brian@bristyle.com>
Subject: Re: Multicast and receive filtering in TUN/TAP
Date: Thu, 10 Jul 2008 19:32:16 -0700
Message-ID: <480487c50807101932u7b4020a8qb31227a85f79c187@mail.gmail.com>
References: <4875428F.4080704@qualcomm.com>
	<7f45d9390807101438q785232f1sfec7fcc580683d0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5795712262500604639=="
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
        Brian Braunstein <linuxkernel@bristyle.com>,
        virtualization@lists.linux-foundation.org,
        Max Krasnyansky <maxk@qualcomm.com>, netdev@vger.kernel.org
To: "Shaun Jackman" <sjackman@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <7f45d9390807101438q785232f1sfec7fcc580683d0f@mail.gmail.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Mime-version: 1.0
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--===============5795712262500604639==
Content-Type: multipart/alternative;
	boundary="----=_Part_19321_6728402.1215743536998"

------=_Part_19321_6728402.1215743536998
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Sorry that I was confused here and it seems I am still confused.

I was thinking that for any one instance of a TAP interface, there should be
only 1 MAC address, since there is only 1 network interface, since the
character device is not a network interface but rather the interface for the
application to send and receive on that virtual network interface.

For the MC stuff, I have to admit I haven't looked into it much, but it
seems like the basic operation of setting the MAC address of the network
interface should be supported, and it seems like an ioctl called
SIOCSIFHWADDR should Set the InterFace HardWare ADDRess.  Sorry if I was
wrong about this.  It might be good to add a comment to SIOCSIFHWADDR that
says "This does not actually set the network interface hardware address,
this is for multicast filtering" or whatever it actually is suppose to do.
Or perhaps create a new ioctl that has something about multicast filtering
in the name, and leave SIOCSIFHWADDR doing what it is doing now.

brian


On Thu, Jul 10, 2008 at 2:38 PM, Shaun Jackman <sjackman@gmail.com> wrote:

> Hi Max,
>
> The original patch implemented receive multicast filtering by
> emulating the implementation used by many physical Ethernet
> interfaces: hashing the multicast address. TUN emulates two network
> cards (and communication via the virtual link between them), the guest
> and the host, or the character device and the network device, so there
> are two receive filters: chr_filter and net_filter. I implemented the
> filtering at the character device using chr_filter in tun_chr_readv,
> and left filtering at the network device for someone else to
> implement.
>
> I'm not sure what you mean by TX filtering. Multicast filtering is
> implemented uniquely at the receiver. There are, however, two
> receivers: the character device and the network device.
>
> I believe Brian's patch was mistaken. Two entirely distinct Ethernet
> addresses are required: one for the character device and one for the
> network device, or put another way, one for the virtual Ethernet
> interface at the guest and one for the virtual Ethernet interface at
> the host. For the same reason, there are two distinct multicast
> filters.
>

>
> Looking over the original patch, I believe I see a bug in tun_net_mclist:
> memset(tun->chr_filter, 0, sizeof tun->chr_filter);
> should be
> memset(tun->net_filter, 0, sizeof tun->net_filter);
>
> Cheers,
> Shaun
>
> On Wed, Jul 9, 2008 at 3:58 PM, Max Krasnyansky <maxk@qualcomm.com> wrote:
> > Yesterday while fixing xoff stuckiness issue in the TUN/TAP driver I got
> a
> > chance to look into the multicast filtering code in there. And
> immediately
> > realized how terribly broken & confusing it is. The patch was originally
> > done by Shaun (CC'ed) and went in without any proper ACK from me, Dave or
> > Jeff.
> > Here is the original ref
> >        http://marc.info/?l=linux-netdev&m=110490502102308&w=2
> >
> > I'm not going to dive into too much details on what's wrong with the
> current
> > code. The main issues are that it mixes RX and TX filtering which are
> > orthogonal, and it reuses ioctl names and stuff for manipulating TX
> filter
> > state as if it was a normal RX multicast state.
> > Later on Brian's patch added insult to the injury
> >        http://git.kernel.org/?p=linux/kernel/git/\<http://git.kernel.org/?p=linux/kernel/git/%5C>
> >                torvalds/linux-2.6.git;\
> >                a=commit;h=36226a8ded46b89a94f9de5976f554bb5e02d84c
> > Brian missed the point of the original patch (not his fault, as I said
> the
> > original patch was not the best) that the separate address introduced by
> the
> > MC patch was used for filtering _TX_ packets. It had nothing to do with
> the
> > HW addr of the local network interface.
> >
> > The problem is that MC stuff is now even more broken and ioctls that were
> > used originally now mean something different. So my first thinking was to
> > just rip the MC stuff out because it's broken and probably nobody uses it
> > (given that we got no complains after Brian's patch broke it completely).
> > But then I realized that if done properly it might be very useful for
> > virtualization.
> >
> > ---
> >
> > So the first question is are there any users out there that ever used the
> > original patch. Shaun, any insight ? How did you intend to use it ?
> >
> > ---
> >
> > The second question is do you guys think that QEMU/KVM/LGUEST/etc would
> > benefit if receive filtering was done by the host OS. Here is a specific
> > example of what I'm talking about.
> > We can do what qemu/hw/e1000.c:receive_filter() does in the _host_
> context
> > (that function currently runs in the guest context). By looking at
> libvirt,
> > typical QEMU based setup is that you have a single bridge and all the
> TAPs
> > from different VMs are hooked up to that bridge. What that means is that
> if
> > one VM is getting MC traffic or when the bridge sees MACADDR that is not
> in
> > its tables the packets get delivered to all the VMs. ie We have to wake
> all
> > of the up only to so that they could drop that packet. Instead, we could
> > setup filters in the host's side of the TAP device.
> > Does that sound like something useful for QEMU/KVM ?
> > If yes we can talk about the API. If not then I'll just nuke it.
> >
> > Thanx
> > Max
> >
>

------=_Part_19321_6728402.1215743536998
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Sorry that I was confused here and it seems I am still confused.<br><br>I was thinking that for any one instance of a TAP interface, there should be only 1 MAC address, since there is only 1 network interface, since the character device is not a network interface but rather the interface for the application to send and receive on that virtual network interface.<br>
<br>For the MC stuff, I have to admit I haven&#39;t looked into it much, but it seems like the basic operation of setting the MAC address of the network interface should be supported, and it seems like an ioctl called SIOCSIFHWADDR should Set the InterFace
HardWare ADDRess.&nbsp; Sorry if I was wrong about this.&nbsp; It might be good to add a comment to SIOCSIFHWADDR that says &quot;This does not actually set the network interface hardware address, this is for multicast filtering&quot; or whatever it actually is suppose to do.&nbsp; Or perhaps create a new ioctl that has something about multicast filtering in the name, and leave SIOCSIFHWADDR doing what it is doing now.<br>
<br>brian<br><br><br>On Thu, Jul 10, 2008 at 2:38 PM, Shaun Jackman &lt;<a href="mailto:sjackman@gmail.com">sjackman@gmail.com</a>&gt; wrote:<br><div class="gmail_quote"><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
Hi Max,<br>
<br>
The original patch implemented receive multicast filtering by<br>
emulating the implementation used by many physical Ethernet<br>
interfaces: hashing the multicast address. TUN emulates two network<br>
cards (and communication via the virtual link between them), the guest<br>
and the host, or the character device and the network device, so there<br>
are two receive filters: chr_filter and net_filter. I implemented the<br>
filtering at the character device using chr_filter in tun_chr_readv,<br>
and left filtering at the network device for someone else to<br>
implement.<br>
<br>
I&#39;m not sure what you mean by TX filtering. Multicast filtering is<br>
implemented uniquely at the receiver. There are, however, two<br>
receivers: the character device and the network device.<br>
<br>
I believe Brian&#39;s patch was mistaken. Two entirely distinct Ethernet<br>
addresses are required: one for the character device and one for the<br>
network device, or put another way, one for the virtual Ethernet<br>
interface at the guest and one for the virtual Ethernet interface at<br>
the host. For the same reason, there are two distinct multicast<br>
filters.<br></blockquote><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;"><br>
<br>
Looking over the original patch, I believe I see a bug in tun_net_mclist:<br>
memset(tun-&gt;chr_filter, 0, sizeof tun-&gt;chr_filter);<br>
should be<br>
memset(tun-&gt;net_filter, 0, sizeof tun-&gt;net_filter);<br>
<br>
Cheers,<br>
<font color="#888888">Shaun<br>
</font><div><div></div><div class="Wj3C7c"><br>
On Wed, Jul 9, 2008 at 3:58 PM, Max Krasnyansky &lt;<a href="mailto:maxk@qualcomm.com">maxk@qualcomm.com</a>&gt; wrote:<br>
&gt; Yesterday while fixing xoff stuckiness issue in the TUN/TAP driver I got a<br>
&gt; chance to look into the multicast filtering code in there. And immediately<br>
&gt; realized how terribly broken &amp; confusing it is. The patch was originally<br>
&gt; done by Shaun (CC&#39;ed) and went in without any proper ACK from me, Dave or<br>
&gt; Jeff.<br>
&gt; Here is the original ref<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp;<a href="http://marc.info/?l=linux-netdev&amp;m=110490502102308&amp;w=2" target="_blank">http://marc.info/?l=linux-netdev&amp;m=110490502102308&amp;w=2</a><br>
&gt;<br>
&gt; I&#39;m not going to dive into too much details on what&#39;s wrong with the current<br>
&gt; code. The main issues are that it mixes RX and TX filtering which are<br>
&gt; orthogonal, and it reuses ioctl names and stuff for manipulating TX filter<br>
&gt; state as if it was a normal RX multicast state.<br>
&gt; Later on Brian&#39;s patch added insult to the injury<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp;<a href="http://git.kernel.org/?p=linux/kernel/git/%5C" target="_blank">http://git.kernel.org/?p=linux/kernel/git/\</a><br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;torvalds/linux-2.6.git;\<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;a=commit;h=36226a8ded46b89a94f9de5976f554bb5e02d84c<br>
&gt; Brian missed the point of the original patch (not his fault, as I said the<br>
&gt; original patch was not the best) that the separate address introduced by the<br>
&gt; MC patch was used for filtering _TX_ packets. It had nothing to do with the<br>
&gt; HW addr of the local network interface.<br>
&gt;<br>
&gt; The problem is that MC stuff is now even more broken and ioctls that were<br>
&gt; used originally now mean something different. So my first thinking was to<br>
&gt; just rip the MC stuff out because it&#39;s broken and probably nobody uses it<br>
&gt; (given that we got no complains after Brian&#39;s patch broke it completely).<br>
&gt; But then I realized that if done properly it might be very useful for<br>
&gt; virtualization.<br>
&gt;<br>
&gt; ---<br>
&gt;<br>
&gt; So the first question is are there any users out there that ever used the<br>
&gt; original patch. Shaun, any insight ? How did you intend to use it ?<br>
&gt;<br>
&gt; ---<br>
&gt;<br>
&gt; The second question is do you guys think that QEMU/KVM/LGUEST/etc would<br>
&gt; benefit if receive filtering was done by the host OS. Here is a specific<br>
&gt; example of what I&#39;m talking about.<br>
&gt; We can do what qemu/hw/e1000.c:receive_filter() does in the _host_ context<br>
&gt; (that function currently runs in the guest context). By looking at libvirt,<br>
&gt; typical QEMU based setup is that you have a single bridge and all the TAPs<br>
&gt; from different VMs are hooked up to that bridge. What that means is that if<br>
&gt; one VM is getting MC traffic or when the bridge sees MACADDR that is not in<br>
&gt; its tables the packets get delivered to all the VMs. ie We have to wake all<br>
&gt; of the up only to so that they could drop that packet. Instead, we could<br>
&gt; setup filters in the host&#39;s side of the TAP device.<br>
&gt; Does that sound like something useful for QEMU/KVM ?<br>
&gt; If yes we can talk about the API. If not then I&#39;ll just nuke it.<br>
&gt;<br>
&gt; Thanx<br>
&gt; Max<br>
&gt;<br>
</div></div></blockquote></div><br>

------=_Part_19321_6728402.1215743536998--

--===============5795712262500604639==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/virtualization
--===============5795712262500604639==--
