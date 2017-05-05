From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: Question about SOCK_SEQPACKET
Date: Fri, 5 May 2017 10:45:00 +0100
Message-ID: <af19f11a-1bc3-bb8f-faf6-65c11b632bbf@redhat.com>
References: <CAGtMfeCt95bj3-J5+TNb5gxVJUBDrgRjMXqMz-3jk9cOh0Z=tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Sam Kumar <samkumar99@gmail.com>, linux-kernel@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGtMfeCt95bj3-J5+TNb5gxVJUBDrgRjMXqMz-3jk9cOh0Z=tA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


On 05/05/17 06:18, Sam Kumar wrote:
> Hello,
> I have recently had occasion to use SOCK_SEQPACKET sockets on Linux,
> and noticed some odd behavior. When using sendmsg and recvmsg with
> these sockets, it seems that the "end-of-record" flag (MSG_EOR) is not
> being propagated correctly.
It depends which protocol you are using as to whether that is true. 
SOCK_SEQPACKET is supposed to be identical to SOCK_STREAM except for the 
record separators. That is true for DECnet (but whether DECnet is still 
functional is another thing!) and not true for ax.25 which uses 
SOCK_SEQPACKET incorrectly. For AF_UNIX that you are using I'm not quite 
sure what would be expected.

> The man page for recvmsg(2) states:
>> The  msg_flags  field  in the msghdr is set on return of recvmsg().  It
>>         can contain several flags:
>>
>>         MSG_EOR
>>                indicates end-of-record; the data returned  completed  a  record
>>                (generally used with sockets of type SOCK_SEQPACKET).
>>
> The man page for recvmsg(3) states:
>> For
>>        message-based  sockets,  such as SOCK_DGRAM and SOCK_SEQPACKET, the entire
>>        message shall be read in a single operation.
>
>
> This leads me to believe that MSG_EOR should be set in the msghdr
> struct whenever recvmsg() returns data. However, I am not observing
> this flag ever being set, whether or not I set the MSG_EOR when
> sending the messages.
>
> If it helps you can take a look at the code I'm using. It is at
> https://github.com/samkumar/seqpacket-test/, commit
> 2a7dbc1f94bafce6950ee726bdd54da96945d083 (HEAD of master at the time
> of writing). Look at server.c and client.c (don't bother with
> goclient.go).
>
> The reason that I need to check MSG_EOR is that I need to distinguish
> between EOF and messages of length 0. For SOCK_STREAM sockets, a
> return value of 0 unambiguously means EOF, and for SOCK_DGRAM sockets
> a return value of 0 unambiguously means that a datagram of length 0
> was received.
>
> Because SOCK_SEQPACKET is both connection-based and message-oriented,
> a return value of 0 is ambiguous. Based on my reading of the man
> pages, reading the MSG_EOR bit would let me disambiguate between EOF
> and a zero-length datagram, because MSG_EOR would be set for a
> zero-length datagram, but would not be set for EOF.
>
> If someone could please help me understand MSG_EOR, and how to
> distinguish between EOF and zero-length messages in a SOCK_SEQPACKET
> connection, I would definitely appreciate it!
>
> Thanks,
> Sam Kumar
That would be my expectation of how it should work - if you ignore 
MSG_EOR on recvmsg then what you get is identical to a SOCK_STREAM, and 
that every call to recvmsg will return data from (at most) a single 
message, with MSG_EOR set if the end of that message has been reached. 
That is what POSIX says should happen anyway.

I do wonder if the man page for recvmsg is wrong, or at least a bit 
confusing. SOCK_SEQPACKET is stream based not message based - it just 
happens to have EOR markers in the stream. There is no reason that the 
whole message needs to be returned in a single read, and in fact that 
would be impossible if the sender didn't insert any EOR markers but kept 
sending data beyond the size that the socket could buffer.

I notice that man 7 socket says SOCK_SEQPACKET is for datagrams of fixed 
maximum length which is definitely wrong, as is the statement that a 
consumer has to read an entire packet with each system call.

Also it is probably better to ask this question on netdev where it is 
likely to get more attention from the net developers, so I'm copying my 
reply there too,

Steve.
