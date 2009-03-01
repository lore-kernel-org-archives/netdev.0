From: Andrew Grover <andy.grover@gmail.com>
Subject: ***SPAM*** Re: [ofa-general] [PATCH 0/26] Reliable Datagram Sockets
	(RDS), take 2
Date: Sat, 28 Feb 2009 16:58:25 -0800
Message-ID: <c0a09e5c0902281658v48084cd8w8f95871395020e20@mail.gmail.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
	<87myc73izx.fsf@basil.nowhere.org>
	<c0a09e5c0902271753n1a522647g6e7ac5465149c5a4@mail.gmail.com>
	<20090228055608.GB26292@one.firstfloor.org>
	<c0a09e5c0902281244u356acbecn98f37ac3abd5ebc0@mail.gmail.com>
	<20090228223653.GD26292@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090228223653.GD26292@one.firstfloor.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 28, 2009 at 2:36 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> The previous solution for IPC that Oracle was using was based on UDP,
>> which I think could be considered very close to using raw sockets --
>> each process is responsible for its own acks, retransmits, everything.
>> Doing this on a highly loaded machine resulted in a cascade where
>> performance got worse and worse.
>
> Could you describe that cascade in more detail?
> The problem was that the retransmits didn't have high enough priority?

I think the gist of it is:

Higher load -> more time before a process runs -> rcvbuf overfills ->
ACKs dropped -> timeouts -> more retransmissions -> even higher load.

Things are fine until they hit a point where everything goes to hell.

>> Additionally, our interconnect is primarily Infiniband. It natively
>> implements a reliable datagram connection type so RDS leverages that.
> So perhaps it would make more sense to have a thin direct interface
> to that IB service? Or perhaps it already exists? (I admit I don't know
> the IB interfaces very well)

The most direct userspace API is uDAPL -- apps can create IB
connections (queue pairs) directly. This was tried but didn't work out
so well. A queue pair (QP) is a TX/RX ring -- a nontrivial amount of
memory. If each process needs a new QP to talk to every other process
then the number of RAM-hungry QPs becomes huge.

RDS is only slightly less direct -- apps don't create queue pairs,
they create RDS sockets. RDS uses only one QP for all traffic to each
remote node, so the number of QPs on a node is equal to the number of
remote nodes, as opposed to (number of local processes * number of
remote processes).

Regards -- Andy
