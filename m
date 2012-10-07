From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH] Packet mmap : allow the user to choose the offset of the
 tx payload.
Date: Sun, 7 Oct 2012 12:50:56 +0200
Message-ID: <CAD6jFUS+ovW79iOZxN-ptTZiTF9VsYnoLA-aWFSBX-zUR8OKGQ@mail.gmail.com>
References: <1349442629-10960-1-git-send-email-paul.chavent@onera.fr>
	<CAD6jFUTmNiRHdAkckkwcV2rEOf_kxjHmntTO+rG6ewLs-RhFfg@mail.gmail.com>
	<7b317aa8fa2c96f3bf7ce916d18eb550@sybille.onecert.fr>
	<CAD6jFURTMDL6WFGOJhMdnS3zuejYm0uaBPb1TYuNNdUS-7w89w@mail.gmail.com>
	<0a20d3610fc578b516cad3f81d14bf50@sybille.onecert.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, edumazet@google.com, xemul@parallels.com,
	herbert@gondor.hengli.com.au, netdev@vger.kernel.org,
	johann.baudy@gnu-log.net, uaca@alumni.uv.es
To: pchavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43939 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab2JGKvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 06:51:06 -0400
Received: from [78.46.4.229] (helo=sslproxy03.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TKoRq-00040K-LR
	for netdev@vger.kernel.org; Sun, 07 Oct 2012 12:51:02 +0200
Received: from [74.125.83.46] (helo=mail-ee0-f46.google.com)
	by sslproxy03.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TKoO1-0006rK-63
	for netdev@vger.kernel.org; Sun, 07 Oct 2012 12:47:05 +0200
Received: by mail-ee0-f46.google.com with SMTP id b15so2214150eek.19
        for <netdev@vger.kernel.org>; Sun, 07 Oct 2012 03:50:56 -0700 (PDT)
In-Reply-To: <0a20d3610fc578b516cad3f81d14bf50@sybille.onecert.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 6, 2012 at 9:43 AM, pchavent <Paul.Chavent@onera.fr> wrote:
> On Fri, 5 Oct 2012 21:37:58 +0200, Daniel Borkmann wrote:
>> On Fri, Oct 5, 2012 at 9:21 PM, pchavent <Paul.Chavent@onera.fr> wrote:
>>> On Fri, 5 Oct 2012 16:17:12 +0200, Daniel Borkmann wrote:
>>>> On Fri, Oct 5, 2012 at 3:10 PM, Paul Chavent <Paul.Chavent@onera.fr>
>>>> wrote:
>>>>>
>>>>>
>>>>> The tx offset of packet mmap tx ring used to be :
>>>>> (TPACKET2_HDRLEN - sizeof(struct sockaddr_ll))
>>>>>
>>>>> The problem is that depending on the usage of SOCK_DGRAM or
>>>>> SOCK_RAW, the payload could be aligned or not.
>>>>>
>>>>> This patch allow to let the user give an offset for it's tx
>>>>> payload if he desires.
>>>>>
>>>>> Signed-off-by: Paul Chavent <paul.chavent@onera.fr>
>>>>
>>>>
>>>> Can you provide an example when it doesn't hit TPACKET_ALIGNMENT?
>>>
>>>
>>> When we use tx ring, the user have to write at (TPACKET_HDRLEN -
>>> sizeof(struct sockaddr_ll))
>>>
>>> This adress is aligned on TPACKET_ALIGNMENT since
>>> TPACKET_HDRLEN = (TPACKET_ALIGN(sizeof(struct tpacket_hdr)) +
>>> sizeof(struct
>>> sockaddr_ll))
>>>
>>> When we use the tx ring with SOCK_RAW option, the mac header is aligned
>>> on
>>> TPACKET_ALIGNMENT, but not the payload (14 bytes away).
>>
>>
>> Okay, I'm confused about your intentions, maybe I'm missing something.
>> The man-page of packet(7) clearly says:
>>
>> The socket_type is either SOCK_RAW for raw packets *including* the
>> link level header or SOCK_DGRAM for cooked packets with  the link
>> level header *removed*.
>>
>> So this is perfectly intended behavior of PF_PACKET.
>>
>> Cheers,
>>
>> Daniel
>
>
> Yes, i also expect to be able to include the link level header when i use
> SOCK_RAW.
>
> My intention is to send a frame with this payload (for example) :
> typedef struct
> {
>   double   ts;
>   uint64_t foo;
> } test_t;
>
> So i get a pointer to the raw packet :
> void * raw_packet = frame_base + (TPACKET_HDRLEN - sizeof(struct
> sockaddr_ll));
>
> I cook the header :
> memcpy(raw_packet +  0, dst_addr, sizeof(dst_addr));
> memcpy(raw_packet +  6, src_addr, sizeof(src_addr));
> memcpy(raw_packet + 12, type    , sizeof(type));
>
> Then i get a pointer to the beginning of payload :
> test_t * payload = raw_packet + 14;
>
> Here payload is at 58 bytes from the beginning of the frame.
>
> Then i fill the payload :
> payload->ts = 1.0;
> payload->foo = 2;
> ...
>
> These are misaligned accesses.
>
> I don't care to fill the cooked header if it's misaligned, but i would like
> to be able to fill the frame directly in the ring buffer being on aligned
> boundaries.

Okay.

Maybe what you could do in a new version of your patch is to introduce
a TP_STATUS flag, e.g. TP_STATUS_SEND_HAS_OFF that you pass along
binary or'ed with the commonly used flags, and then you can fill
tp_mac resp. tp_net with offsets. By that, you won't break legacy
stuff.
