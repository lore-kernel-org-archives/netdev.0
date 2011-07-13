From: Rick Jones <rick.jones2@hp.com>
Subject: Re: any way to let host act as TCP server OR client on same IP/port?
Date: Wed, 13 Jul 2011 13:36:15 -0700
Message-ID: <4E1E01BF.3040201@hp.com>
References: <4E1DC83C.3020506@genband.com>	<1310579520.2509.17.camel@edumazet-laptop>	<4E1DDE62.3080503@hp.com> <4E1DEEF9.7040901@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:38005 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab1GMUgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 16:36:16 -0400
In-Reply-To: <4E1DEEF9.7040901@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> I was thinking the same thing, but it appears to not work under:
>
> <snip>
>
>> if (bind(listener,
>> (struct sockaddr *)&me,
>> sizeof(me))<  0) {
>> perror("bind listener");
>> exit(-1);
>> }
>>
>> if (listen(listener,128)<  0) {
>> perror("listen listener");
>> exit(-1);
>> }
>>
>> /* connect something to it */
>> if (connect(client,(struct sockaddr *)&me,sizeof(me))<  0) {
>> perror("connect client");
>> exit(-1);
>
> In our case we don't need to actually be connected, just be listening
> and ready to either accept() a connection or connect() to someone else.

If one calls listen() against a socket, TCP connections can be 
established at any time, before the accept() calls are made.  As for 
what might happen when one calls connect() on a listen socket when there 
are queued connections awaiting accept() I've no idea.  Presumably they 
would follow the same path as if close() were called against the listen 
endpoint before they were accept()ed.  And if the listen endpoint is 
transitioned to CONNECTED then any subsequently arriving connection 
requests will likely elicit RSTs back to their senders.

If your application's sematics are OK with pending connections being 
dumped, and there is no issue with something else binding to IP,port and 
putting it into the LISTEN state, and if I've read between the lines of 
what you've written correctly, you could simply close() the listen 
socket and create a fresh socket with which to do the connect()?

I think it is only if you need both accepting new connections and 
calling connect() all in parallel that you need enhancements to the stack.

> However, even after removing the connect() call I get:
> "bind active: Address already in use"

Some of this behaviour may come from the "standards" (either formal or 
informal), and what they call for for error returns on the different 
calls under what conditions.

Historically, and not necessarily specific to any one stack, 
SO_REUSEADDR allows one to kill a server application, and restart it and 
get its LISTEN endpoint restarted even while there are old connections 
with IP,port as half the four-tuple (esp TIME_WAITs).  But SO_REUSEADDR 
won't allow the bind(IP,port) to succeed if there is another listen() 
endpoint bound to that IP,port.  That would be an ambiguity.  But, if 
the second endpoint to be bound to IP,port doesn't go listen(), there 
isn't an ambiguity.  This may be where the standards or historical 
expectations come-in if they "require" the bind() fail even if it isn't 
clear there will be a subsequent listen() call against that endpoint.

Presumably, as far as the TCP state machine goes, having one endpoint 
bound only to IP1,Port1 and in the LISTEN state and one simply bound to 
IP,port but not in LISTEN (presumably on its way to a connection 
establishment) is ok.  A arriving segment will hit the four-tuple if it 
exists, and only go to the two-tuple if is in LISTEN and the segment is 
a SYN and won't go to the non-listen two-tuple at all.  But at the API 
level the listen() and connect() calls need to be permitted/able to 
return EADDRINUSE (or something akin) when they then try to create a 
two/four-tuple (listen/connect) that is already in use.

FWIW, the listen() manpage on my Maverick system does list:

ERRORS
        EADDRINUSE
               Another socket is already listening on the same port.

suggesting that the "delay the failure until listen() on the same 
IP,port" is possible, but I don't know if that is vestigial manpage 
cruft or "real."  The manpage for connect() shows EADDRINUSE as well - 
again though I not sure if that is vestigial, so it may not accurately 
convey current stack intent.

> The TCP state machine shows a single connection going from LISTEN to
> SYN_SENT via a "send" operation in the application.  Presumably this
> would logically map to a sendto/sendmsg but according to the man page
> those don't support specifying addresses for connection-oriented
> sockets.  I tried it anyways and got no errors but the following trace
> shows that it's dying with SIGPIPE:
>
> bind(3, {sa_family=AF_INET, sin_port=htons(23456), sin_addr=inet_addr("127.0.0.1")}, 16) = 0
> listen(3, 128)                          = 0
> sendto(3, "\1", 1, 0, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("127.0.0.1")}, 16) = -1 EPIPE (Broken pipe)
> --- {si_signo=SIGPIPE, si_code=SI_USER, si_pid=20609, si_uid=8382, si_value={int=2722689790, ptr=0x3ca248f2fe}} (Broken pipe) ---
> +++ killed by SIGPIPE +++

You might try a connect() call - since T/TCP (vs the even older than 
netperf, ttcp benchmark :) never caught-on, sendto() against a TCP 
endpoint is probably a no-go.

If I'm thinking of the same state machine diagram, the "send" is rather, 
well, generic and does not map directly to any API.

(I tried it very quick and dirty, with no joy)

If your application's sematics are OK with pending connections being 
dumped, and there is no issue with something else
rick
