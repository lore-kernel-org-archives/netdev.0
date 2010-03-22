From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Add PGM protocol support to the IP stack
Date: Mon, 22 Mar 2010 11:51:08 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1003221146260.17230@router.home>
References: <alpine.DEB.2.00.1003181245050.23010@router.home> <87tysccjrn.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003220916170.15360@router.home> <20100322163609.GZ20695@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100322163609.GZ20695@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Mar 2010, Andi Kleen wrote:

> Multicast reliable kernel protocols are somewhat new, I guess one
> would need to make sure to come up with a clean generic interface
> for them first.

It has been around for a long time in another OS. I wonder if I should use
the socket API realized there as a model or come up with something new
from scratch?

What I have right now is:

1. Opening a socket

        A. Native PGM

                fd = socket(AF_INET, SOCK_RDM, IPPROTO_PGM)

        B. PGM over UDP

                fd = socket(AF_INET, SOCK_RDM, IPPROTO_UDP)

        C. PGM over SHM (?)

                fd = socket(AF_UNIX, SOCK_RDM, 0)


2. Binding to a multicast address

        A. Sender

                Connect the socket to a MC address and port using connect().

                Note that the port is significant since multiple streams on different
                ports can be run over the same MC addr.

        B. Receiver

                I. Bind the socket to the MC address and port of interest.

                II. Listen to the socket.

                        Process will wait until a PGM packet destined to the port of interest
                        is received.

                III. Accept a connection.

                        Establishes a session. Data can then be received.


3. Sending and receiving

        Use the usual socket read and write operations and the various flavors of waiting
        for a packet via select, poll, epoll etc.

        Packet sizes are determined by the number of  packets in a single sendmsg() unless
        overridden by the RM_SET_MESSAGE_BOUNDARY socket option.

        The sender will block when the send window is full unless a non blocking write is performed.

        The receiver shows the usual wait semantics. If the stream is set to unreliable then
        packets may arrive in random order. If the set is set to RM_LISTEN_ONLY then packets may
        just be missing.

4.      Transmitter Socket Options


        A. Setting the window size / rate.

                struct pgm_send_window x;
                x.RateKbitsPerSec = 56;
                x.WindowSizeInMsecs = 60000;
                x.WindowSizeinBytes = 10000000;

                setsockopt(fd, SOCK_RDM, RM_RATE_WINDOW_SIZE, &x, sizeof(x));

                Default is sending at 56Kbps with a buffer of 10 Megabytes and buffering for a minute.

        B. FEC mode

                struct pgm_fec_info x;

                x.FECBlocksize = 255;
                x.FECProActivePackets = 0;
                x.FECGroupSize = 0;
                x.fFECOnDemandParityEnabled = 1;

                setsockopt(fd, SOCK_RDM, RM_FEC_MODE, &x, sizeof(x));


5.      Receiver Socket Options

        None?


Possible Extensions

        RM_UNORDERED    accept unordered packet avoiding delays when packets arrive out of sequence.
                        packet is still NAKed.

        RM_RECEIVE_ONLY Simply ignore missed packets. Do not send any replies.



Existing socket options in the other OS (X denotes that this looks like
its screwy and should be avoided)

/* PGM socket options */

/* Transmitter */
#define RM_LATEJOIN                             1       /* X Not supported on receive so why have it? */
#define RM_RATE_WINDOW_SIZE                     2       /* See struct pgm_send_window */
#define RM_SEND_WINDOW_ADV_RATE                 3       /* X Increase of send window in percentage of window */
#define RM_SENDER_STATISTICS                    4       /* see struct pgm_sender_stats */
#define RM_SENDER_WINDOW_ADVANCE_METHOD         5       /* X seems obsolete */
#define RM_SET_MCAST_TTL                        6       /* X Can be set via IP_MULTICAST_TTL */
#define RM_SET_MESSAGE_BOUNDARY                 7       /* Fix the size of the messages in bytes */
#define RM_SET_SEND_IF                          8       /* X use IP_MULTICAST_IF etc instead */
#define RM_USE_FEC                              9

/* Receiver */
#define RM_ADD_RECEIVE_IF                       100     /* X ???? IP_MULTICAST_IF instead? */
#define RM_DEL_RECEIVE_IF                       101     /* X IP_MULTICAST_IF */
#define RM_HIGH_SPEED_INTRANET_OPT              102     /* X PGM should adapt automatically to high speed networks */
#define RM_RECEIVER_STATISTICS                  103     /* See struct pgm_receiver_stats */


/* Socket API structures (established by M$DN) */
struct pgm_receiver_stats {
        u64     NumODataPacketsReceived;        /* Number of ODATA (original) sequences */
        u64     NumRDataPacketsReceived;        /* Number of RDATA (repair) sequences */
        u64     NumDuplicateDataPackets;        /* Duplicate sequences */
        u64     DataBytesReceived;
        u64     TotalBytesReceived;
        u64     RateKBitsPerSecOverall;         /* Receive rate since start of session X */
        u64     RateKBitsPerSecLast;            /* Receive rate for last second X*/
        u64     TrailingEdgeSeqId;              /* Oldest sequence in the receive window */
        u64     LeadingEdgeSeqId;               /* Newest sequence in the receive window */
        u64     AverageSequencesInWindow;       /* Average number of sequences in receive window X */
        u64     MinSequencesInWindow;           /* The mininum number of sequences */
        u64     MaxSequencesInWindow;           /* The maximum number of sequences */
        u64     FirstNakSequenceNumber;         /* First outstanding nack sequence number */
        u64     NumPendingNaks;                 /* Number of sequences waiting for NCF */
        u64     NumOutstandingNaks;             /* Number of sequences waiting for RDATA */
        u64     NumDataPacketsBuffered;         /* Number of packets currently buffered */
        u64     TotalSelectiveNaksSent;         /* Number of NAKs sent total */
        u64     TotalParityNaksSent;            /* Number of parity NAKs sent */
};

struct pgm_sender_stats {
        u64     DataBytesSent;
        u64     TotalBytesSent;
        u64     NaksReceived;
        u64     NaksReceivedTooLate;            /* NAKs received after receive window advanced */
        u64     NumOutstandingNaks;             /* Number of NAKs awaiting response */
        u64     NumNaksAfterRData;              /* Number of NAKs after RDATA sequences were sent which were ignored */
        u64     RepairPacketsSent;
        u64     BufferSpaceAvailable;           /* Number of partial messages dropped */
        u64     TrailingEdgeSeqId;              /* Oldest sequence id in window */
        u64     LeadingEdgeSeqId;               /* Newest sequence id in window */
        u64     RateKBitsPerSecOverall;         /* Rate since start of session X */
        u64     RateKBitsPerSecLast;            /* Rate in last second X */
        u64     TotalODataPacketsSent;          /* Total data packets transmitted */
};

/* Setup of sender RateKbitsPerSec = WindowSizeBytes / WindowSizeMSecs */
struct pgm_send_window {
        u64     RateKbitsPerSec;                /* Allowed rate for the sender in kbits per second */
        u64     WindowSizeInMSecs;              /* Send window size in time */
        u64     WindowSizeInBytes;              /* Window size in bytes */
};

struct pgm_fec_info {
        u16     FECBlockSize;                   /* Maximum number of packets for a group. Default and max = 255 */
        u16     FECProActivePackets;            /* Number of proactive packets per group. */
        u8      FECGroupSize;                   /* Number of packets to be treated as a group. Power of two */
        int     fFECOnDemandParityEnabled;      /* Allow sender to sent parity repair packets */
};
