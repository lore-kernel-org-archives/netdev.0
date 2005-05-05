From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000 (?) jumbo frames performance issue
Date: Thu, 05 May 2005 16:24:25 -0700
Message-ID: <427AAB29.8040607@hp.com>
References: <200505051928.32496.m.iatrou@freemail.gr> <427A7F5B.8050704@hp.com>	<20050505143318.004566a9.davem@davemloft.net>	<427A9623.5060402@hp.com> <20050505151720.075e4a91.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: m.iatrou@freemail.gr
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050505151720.075e4a91.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 05 May 2005 14:54:43 -0700 Rick Jones <rick.jones2@hp.com> wrote:
> 
> 
>> assuming of course that the intent of the algorithm was to try to get the
>> average header/header+data ratio to something around 0.9 (although IIRC,
>> none of a 537 byte send would  be delayed by Nagle since it was the size of
>> the user's send being >= the MSS, so make that ~0.45 ?)
> 
> 
> It tries to hold smaller packets back in hopes to get some more sendmsg() 
> calls which will bunch up some more data before all outstanding data is 
> ACK'd.

I think we may be saying _nearly_ the same thing, although I would call that
smaller user sends.  Nothing I've read (and remembered) suggested that a user 
send of MSS+1 bytes should have that last byte delayed.  That's were I then got 
that handwaving math of 0.45 instead of 0.9.

My bringing up the ratio of header to header+data comes from stuff like this in 
rfc896:

<begin>
                    The small-packet problem

There is a special problem associated with small  packets.   When
TCP  is  used  for  the transmission of single-character messages
originating at a keyboard, the typical result  is  that  41  byte
packets  (one  byte  of data, 40 bytes of header) are transmitted
for each byte of useful data.  This 4000%  overhead  is  annoying
but tolerable on lightly loaded networks.  On heavily loaded net-
works, however, the congestion resulting from this  overhead  can
result  in  lost datagrams and retransmissions, as well as exces-
sive propagation time caused by congestion in switching nodes and
gateways.   In practice, throughput may drop so low that TCP con-
nections are aborted.
<end>

The reason I make the "user send" versus packet distinction comes from stuff 
like this:

<begin>
The solution is to inhibit the sending of new TCP  segments  when
new  outgoing  data  arrives  from  the  user  if  any previously
transmitted data on the connection remains unacknowledged.
<end>

I do acknowledge though that there have been stacks that interpreted Nagle on a 
segment by segment basis rather than a user send by user send basis.  I just 
don't think that they were correct :)

> 
> It's meant for terminal protocols and other chatty sequences.
> 

He included an FTP example with 512 byte sends which leads me to believe it was 
meant for more than just terminal protocols:

<begin>
We use our scheme for all TCP connections, not just  Telnet  con-
nections.   Let us see what happens for a file transfer data con-
nection using our technique. The two extreme cases will again  be
considered.

As before, we first consider the Ethernet case.  The user is  now
writing data to TCP in 512 byte blocks as fast as TCP will accept
them.  The user's first write to TCP will start things going; our
first  datagram  will  be  512+40  bytes  or 552 bytes long.  The
user's second write to TCP will not cause a send but  will  cause
the  block  to  be buffered.
<end>

What I'd forgotten is that the original RFC had no explicit discussion of checks 
against the MSS.  It _seems_ that the first reference to that is in rfc898, 
which was a writeup of meeting notes:

<begin>
Congestion Control -- FACC - Nagle

       Postel:  This was a discussion of the situation leading to the
       ideas presented in RFC 896, and how the policies described there
       improved overall performance.

Hinden, Postel, Muuss, & Reynolds                              [Page 20]



RFC 898                                                       April 1984
Gateway SIG Meeting Notes


       Muuss:

       First principle of congestion control:

          DON'T DROP PACKETS (unless absolutely necessary)

       Second principle:

          Hosts must behave themselves (or else)

          Enemies list -

             1.  TOPS-20 TCP from DEC
             2.  VAX/UNIX 4.2 from Berkeley

       Third principle:

          Memory won't help (beyond a certain point).

          The small packet problem: Big packets are good, small are bad
          (big = 576).

       Suggested fix: Rule: When the user writes to TCP, initiate a send
       only if there are NO outstanding packets on the connection. [good
       for TELNET, at least] (or if you fill a segment). No change when
       Acks come back. Assumption is that there is a pipe-like buffer
       between the user and the TCP.
<end>

with that parenthetical "(or if you fill a segment)" comment.  It is interesting 
how they define "big = 576" :)

It seems the full-sized segment bit gets formalized in 1122:

<begin>
             A TCP SHOULD implement the Nagle Algorithm [TCP:9] to
             coalesce short segments.  However, there MUST be a way for
             an application to disable the Nagle algorithm on an
             individual connection.  In all cases, sending data is also
             subject to the limitation imposed by the Slow Start
             algorithm (Section 4.2.2.15).

             DISCUSSION:
                  The Nagle algorithm is generally as follows:

                       If there is unacknowledged data (i.e., SND.NXT >
                       SND.UNA), then the sending TCP buffers all user



Internet Engineering Task Force                                [Page 98]




RFC1122                  TRANSPORT LAYER -- TCP             October 1989


                       data (regardless of the PSH bit), until the
                       outstanding data has been acknowledged or until
                       the TCP can send a full-sized segment (Eff.snd.MSS
                       bytes; see Section 4.2.2.6).
<end>


> It was not designed with 16K MSS frame sizes in mind.

I certainly agree that those frame sizes were probably far from their minds at 
the time and that basing the decision on the ratio of header overhead is well 
within the spirit.

rick jones
