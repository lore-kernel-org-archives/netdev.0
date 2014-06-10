From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: SCTP's processing of unexpected COOKIE_ECHO doesn't seem useful.
Date: Tue, 10 Jun 2014 14:16:55 -0400
Message-ID: <53974B97.20404@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D17259B99@AcuExch.aculab.com> <53970BB3.5010909@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1725A469@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:55946 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbaFJSQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 14:16:58 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so2802882qcy.1
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 11:16:57 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725A469@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2014 10:09 AM, David Laight wrote:
> From: Vlad Yasevich [ 
>> On 06/10/2014 05:52 AM, David Laight wrote:
>>> I'm seeing some unexpected (to me) behaviour of the SCTP stack
>>> when the remote system restarts.
>>>
>>> I've a socket that has a single association, and I'm rather
>>> expecting TCP-like behaviour.
>>> So I'd expect some kind of failure condition on my existing
>>> connection, and then a new connection be established on a
>>> different socket - eg though a listening socket.
>>> This would then go through all my code for correctly
>>> initialising a new connection.
>>>
>>> What happens is rather different.
>>>
>>> The remote sends an INIT with the same port numbers as the
>>> previous connection, AFAICT the code sends an INIT_ACK with
>>> some numbers taken from the existing TCB.
>>>
>>> When the COOKIE_ECHO is received sctp_sf_do_5_2_4_dupcook()
>>> is called, condition 'A' is detected and sctp_sf_do_dupcook_a()
>>> called.
>>>
>>> RFC 2960 says that this should be treated as a received ABORT
>>> followed by a COOKIE echo - this sounds fine, I want the ABORT
>>> processing to kill the existing connection.
>>> However it then says that 'RESTART' should be indicated to the ULP
>>> rather than 'COMMUNICATION LOST'.
>>>
>>> AFAICT this is just silently ignored by the socket layer.
>>> I've a process sleeping in recv() (actually a kernel thread in
>>> sock_recvmsg()) and it is not woken up at all.
>>
>> You haven't subscribed to receive notifications and as a result
>> you haven't been woken up.
> 
> I've spent some time reading the morass^Wcode and discovered where
> the notification gets dropped.
> 
>> The ABORT treatment above simply resets the state of the original
>> connection, thus simulating the ABORT and a new connection all
>> in one.
> 
> This might be nice for the remote side, but isn't really useful
> for many applications - imagine what ftp would have to do...

Most client/server systems are fine with restart.  The ones that
are affected most are peer-to-peer where either end may initiate
a connection.

> 
>> This is where an application really needs to utilize and process
>> SCTP notifications.  You can also collect data like which messages
>> have not been send to the remote, so that you can re-queue them.
> 
> Yes, I guess the last bit comes from trying to emulate the MTP2 'retrieval',
> however it is probably a waste of time unless all the timers have been
> reduced to a few 10s of milliseconds.
> 
>>> This leaves the 'application' code in completely the wrong state for
>>> the SCTP connection.
>>>
>>
>> I can understand where you are coming from.  There are some useful
>> cases for association restart, but it could also be turned off
>> without much adverse effect to the applications.
> 
> I can image the notifications being useful for UDP style sockets, or
> where the messages themselves are idempotent (maybe something like
> DNS lookups), but if there is any application level state processing
> the RESTART event is probably quite difficult.

There are other protocols which handle RESTARTs just fine.  I know of
plenty M3UA implementations that correctly handle the state.

> 
>> May be a sysctl or a socket option that allows you control whether you
>> want association restart or not might be nice to have.
> 
> A 1-1 TCP-style socket that doesn't have the notifications enabled would
> be a good start.
>

Ok, so a socket options might be best where we don't support a restart
notification, but handle it as "Destroy old association/Create new
association", with all appropriate events.  Since this is a non-standard
behavior, this would have to be explicitly turned on by the application.
May be have a sysctl as well.  This would apply to TCP style sockets.

If you or someone from your team have the time, submit a patch.
Otherwise, it's going to go into the queue and we'll get to it as
some point.

-vlad

> 	David
> 
> 
> 
