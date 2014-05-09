From: Jon Maloy <maloy@donjonn.com>
Subject: Re: [PATCH net-next 1/8] tipc: decrease
	connection flow control window
Date: Fri, 09 May 2014 12:00:43 -0400
Message-ID: <536CFBAB.8050107@donjonn.com>
References: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>
	<1399641209-26112-2-git-send-email-jon.maloy@ericsson.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F71067C@AcuExch.aculab.com>
	<20140509142739.GQ30044@eerihug-hybrid.rnd.ki.sw.ericsson.se>
	<063D6719AE5E284EB5DD2968C1650D6D0F71075B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Jon Maloy' <jon.maloy@ericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	"'erik.hugne@ericsson.com'" <erik.hugne@ericsson.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F71075B@AcuExch.aculab.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 05/09/2014 10:59 AM, David Laight wrote:
> From: erik.hugne@ericsson. 
>> On Fri, May 09, 2014 at 01:30:43PM +0000, David Laight wrote:
>>> Sounds a bit like a badly designed protocol to me...
>> Well, i don't like this either but the current message-oriented flowcontrol
>> will eventually be replaced with a byte-based one. Right now we're trying
>> to find a way to adapt a message-oriented flow control to per-socket buffer
>> constraints, without breaking protocol compatibility.
> I wasn't thinking of the byte/message flow control problems.
> More of only requesting acks every 512 messages

Acks are not requested, they are sent out unsolicited at fix
intervals, controlled by the reading capacity of the receiving
process.

The fundamental problem we have is that we acknowledge
messages, without considering their size, so a sender won't
stop (there is no active stop message from the receiver) until
he has sent 512 messages and not received an ack, which in
the worst case amounts to 512 x truesize(64KB) = 67 MB
outstanding data. This is what the receiving socket must
be able to absorb, in order to avoid broken connections.

If we acknowledge bytes instead of messages and possibly
introduce a flexible acknowledge interval, this whole problem will
go away, but until then (a few months from now, I think) we have do
make the best out of what we have.


> (if my quick reading of the proposed change is right).
> Especially without the receiver being able to stop the sender when
> there is a buffer crisis (of any kind) at the receiver.

To use any form of active feedback to the sender sounds scary
to me. Passive feedback, in the form of withheld acks, is the way
to go. That is the way it works now, and the way it should work,
it is just that the buffer limits we need to sustain this currently
are insanely high.

>
> I guess the aim was to limit the 'back traffic' by making the
> assumption that the receiving system would always be able to
> process the data as fast as it arrived.
> If the receiver is an embedded system this is unlikely to be true.

True.  Legacy TIPC comes from a world where memory constraints
wasn't considered a big issue. That is different now, of course, and
has to be remedied.

>
> I suspect you want the receiver to offer a large window (bytes or messages),
> but on a buffer crisis (per connection or global) be able to tell the
> sender to stop sending.

I believe we rather should put our effort into a byte-oriented, TCP-like
flow control, to permanently solve this issue. As said, it is on our agenda.

> A few messages received while the sender is stopped could still be saved
> (effectively assuming they were sent before the 'stop' was received).
>
> If running over an unreliable transport you'll want to retx the stop in
> case it was lost.

TIPC connections always run over a reliable media, - its own link
layer. This means that the connection layer does not have any
form of sequence numbering or retransmission, -it just assumes
that everything arrives in order and without losses, as long
as the link layer doesn't tell it otherwise.

This isn't really a problem, as long as the connection-level flow
control is able to work within reasonable constraints.  That is
what it is unable to do now, and what we are going remedy once
our drive to redo the locking policy is finished.

Regards
///jon


> If the 'stop' message is an ack, then don't ack the last received message.
> Then you'll get timeout recovery if the 'start' message is lost.
>
> 	David
>
>
>


------------------------------------------------------------------------------
Is your legacy SCM system holding you back? Join Perforce May 7 to find out:
&#149; 3 signs your SCM is hindering your productivity
&#149; Requirements for releasing software faster
&#149; Expert tips and advice for migrating your SCM now
http://p.sf.net/sfu/perforce
