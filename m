From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: SV: [PATCH net-next-2.6 v4 02/12] net-caif: add CAIF socket
 and configuration headers
Date: Sat, 27 Feb 2010 23:58:07 +0100
Message-ID: <1267311487.8849.91.camel@localhost.localdomain>
References: <1267222417-2764-1-git-send-email-sjur.brandeland@stericsson.com>
	 <1267222417-2764-2-git-send-email-sjur.brandeland@stericsson.com>
	 <1267222417-2764-3-git-send-email-sjur.brandeland@stericsson.com>
	 <1267226115.18491.71.camel@violet>
	 <61D8D34BB13CFE408D154529C120E079138CB5@eseldmw101.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Daniel Martensson <daniel.martensson@stericsson.com>,
	kaber@trash.net, stefano.babic@babic.homelinux.org,
	randy.dunlap@oracle.com
To: Sjur =?ISO-8859-1?Q?Br=E6ndeland?=
	<sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:47962 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965496Ab0B0W7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 17:59:43 -0500
In-Reply-To: <61D8D34BB13CFE408D154529C120E079138CB5@eseldmw101.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sjur,

> >I think most issues have been resolved and this should be ready for
> >merging, but I am bit worried about the userspace API. Can we start a
> >bit smaller and extend it later? Especially the socket options worry me
> >a bit.
> 
> >Dave, personally I would prefer if we can merge this without these
> >socket options. Since I am really missing the need for it.
> 
> As mentioned in previous mail to Dave, I will be off traveling,
> so I will not be able to send out anything new in the next four days.
> Which means that we will miss the next pull of net-next-2.6.

it could be possible that Dave makes an exception since it is a new
subsystem and doesn't change anything else. So he might consider this
under the "new driver" exception.

As I mentioned before, I think it is ready to be merged. I am just
worried about the userspace API. Adding socket options at a later point
is easy. Removing or changing them is the part that we can't do.

> >> +/**
> >> + * enum caif_socket_opts - CAIF option values for getsockopt and setsockopt.
> >> + *
> >> + * @CAIFSO_LINK_SELECT:		Selector used if multiple CAIF Link layers are
> >> + *				available. Either a high bandwidth
> >> + *				link can be selected (CAIF_LINK_HIGH_BANDW) or
> >> + *				or a low latency link (CAIF_LINK_LOW_LATENCY).
> >> + *                              This option is of type u_int32_t.
> >> + *				Alternatively SO_BINDTODEVICE can be used.
> >> + *
> >> + * @CAIFSO_REQ_PARAM:		Used to set the request parameters for a
> >> + *				utility channel. (struct caif_param). This
> >> + *				option must be set before connecting.
> >> + *
> >> + * @CAIFSO_RSP_PARAM:		Gets the request parameters for a utility
> 
> It is a typo in the documentation here, s/request/response/. Sorry for the confusion.
> 
> >> + *				channel. (struct caif_param). This option
> >> + *				is valid after a successful connect.
> >
> >These two more look like a combination of setsockopt/getsockopt instead
> >of two socket options. Maybe it is leftover from a ioctl interface, but
> >socket options work differently.
> 
> No the REQ_PARAM and RSP_PARAM are not just reading/writing the same option.
> The CAIF protocol defines "utility channels". This channels are "pipes" between
> processes on the modem and host side.
> The CAIF protocol defines extra request parameters (REQ_PARAM) for Utility
> channels that can be sent from the client to the server in the connect request.
> The server may also send response parameters (RSP_PARAM) in the connect response message. 
> These socket options are used for setting the request parameters and reading the response 
> parameters.
> 
> I think we need these socket options, otherwise we would not be able to support
> the CAIF Utility Links.
> >
> >Also the caif_param struct seems pointless. Socket options contain a
> >length parameter anyway. So why bother with a struct that is just a data
> >field and a length field.
> 
> Yes, I see your point here, I could have skipped this type.

You need to fix the documentation here, because I didn't understand what
it was suppose to be doing. Also I think we should get rid of caif_param
struct before we can merge this.

> >> + * @CAIFSO_CHANNEL_ID:		Gets the channel id on a CAIF Channel.
> >> + *				This option is valid after a successful connect.
> >> + *				( u_int32_t)
> >
> >Where is this used and what is it used for? Is this something that
> >shouldn't be better part of the sockaddr structure. Then you can use
> >getpeername for it?
> 
> CAIF on the modem side generates unique channel IDs for each CAIF Channel.
> This ID identifies the CAIF Channel both on Host and Modem side.
> This socket option gives the Linux Side client a possibility to get hold
> of this client id. 
> This would typically be used for application logging purposes in order to be able to
> correlate host side logs and modem side logs. I could move this to debugfs...
> 
> Personally I would prefer to keep it, but it could be skipped.

Can an application force a specific channel ID? If yes, then this should
be part of the sockaddr_caif structure, if not, the socket option is
fine. I have no preference for debugfs or socket option. It sounds a bit
more like a debug feature.

As a side note, you might wanna mention which ones are read-only etc.

> >> + * @CAIFSO_NEXT_PAKCET_LEN:	Gets the size of next received packet.
> >> + *				Value is 0 if no packet is available.
> >> + *				This option is valid after a successful connect.
> >> + *				( u_int32_t)
> >Typo. And why do we need this?
> 
> This would be used by a client to see the size of the next message to read, allowing
> the client to allocate a buffer of the correct size.
> I agree that this option is not vital.

If you really want this kind of thing then I would say including the
next packet length in CMSG of the message you just read via recvmsg()
would be a way more efficient way. Calling getsockopt() before every
recv() seems pretty much wrong to me.

> >> + * @CAIFSO_MAX_PAKCET_LEN:	Gets the maximum packet size for this
> >> + *				connection. ( u_int32_t)
> >Isn't this more like SO_RCVBUF or SO_SNDBUF.
> 
> CAIF protocol on modem side has a limit on one page size (4096) on the link layer.
> However different CAIF Channel types and Link Layers will result in different
> maximum sizes for each CAIF Channel. This options allows client to see the 
> maximum CAIF packet size can be used in sendmsg. I guess the SO_SNDBUF would have
> slightly different semantic, describing the maximum number of bytes in the hosts send queue.
> 
> If we in the future change this protocol limitation, it would be nice for the host client to
> have this information dynamically pr channel instead of constants in the clients source code.

Looks fine to me. Just needed to understand what it is for. However even
this one has a typo in the documentation ;)

Regards

Marcel


