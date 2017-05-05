From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: Question about SOCK_SEQPACKET
Date: Fri, 5 May 2017 11:34:05 +0100
Message-ID: <e413b04e-b441-604c-f605-c5a28389d064@redhat.com>
References: <CAGtMfeCt95bj3-J5+TNb5gxVJUBDrgRjMXqMz-3jk9cOh0Z=tA@mail.gmail.com>
 <af19f11a-1bc3-bb8f-faf6-65c11b632bbf@redhat.com>
 <20170505100926.GD1547@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sam Kumar <samkumar99@gmail.com>, linux-kernel@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170505100926.GD1547@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


On 05/05/17 11:09, Sowmini Varadhan wrote:
> On (05/05/17 10:45), Steven Whitehouse wrote:
>> I do wonder if the man page for recvmsg is wrong, or at least a bit
>> confusing. SOCK_SEQPACKET is stream based not message based - it just
>> happens to have EOR markers in the stream. There is no reason that the whole
>> message needs to be returned in a single read, and in fact that would be
>> impossible if the sender didn't insert any EOR markers but kept sending data
>> beyond the size that the socket could buffer.
>>
>> I notice that man 7 socket says SOCK_SEQPACKET is for datagrams of fixed
>> maximum length which is definitely wrong, as is the statement that a
>> consumer has to read an entire packet with each system call.
> Which man page do you think is wrong here? The POSIX definition is here
>
> http://pubs.opengroup.org/onlinepubs/009695399/functions/recvmsg.html
>
> The description in
>
> http://pubs.opengroup.org/onlinepubs/009695399/functions/xsh_chap02_10.html
>
> says, "It is protocol-specific whether a maximum record size is imposed."
> In my machine (Ubuntu 4.4.0-72, and it is in socket(2), not socket(7), btw)
> doesnt have any references to max length, but I'm not sure I'd boldly assert
> "definitely wrong" about the requirement of having to read entire
> packet in a system call (see POSIX man page)
>
> --Sowmini
>
Just before the part that you've quoted, the description for 
SOCK_SEQPACKET says:
"The SOCK_SEQPACKET socket type is similar to the SOCK_STREAM type, and 
is also connection-oriented. The only difference between these types is 
that record boundaries are maintained using the SOCK_SEQPACKET type. A 
record can be sent using one or more output operations and received 
using one or more input operations, but a single operation never 
transfers parts of more than one record."

The man page for socket says SOCK_SEQPACKET "Provides  a sequenced,  
reliable,  two-way connection-based data transmission path  for  
datagrams  of  fixed maximum  length" which is not true, because while 
there may be a length restriction, it is quite possible that there is 
not a length restriction (as per DECnet). It also says "a  consumer  is  
required  to read an entire packet with each input system call" which is 
also contradicted by POSIX which says that a record can be "received 
using one or more input operations". So both statements in the man page 
are wrong, I think.

I have to say that I'd not spotted the POSIX recvmsg wording before, 
which says "For message-based sockets, such as SOCK_DGRAM and 
SOCK_SEQPACKET, the entire message shall be read in a single operation" 
however that does contradict the earlier wording, where it explicitly 
says that multiple receive operations per record are ok for 
SOCK_SEQPACKET - at least if we assume that record == message in this 
case. Also, if this restriction was true (one message per recvmsg call) 
then MSG_EOR would never be needed on receive, since every recvmsg would 
be a single message/record only, and that same document does say that 
MSG_EOR can be set on receive for protocols which support it,

Steve.
