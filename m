From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] Extended Generic Packet Classifier
Date: Thu, 23 Dec 2004 20:48:34 +0100
Message-ID: <20041223194834.GF7884@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	The following patch contains the classifier I've been talking
about a few times already. It builds upon the exiting cls api and provides
an extended api to so called keys. It's not something totally new but
rather a collection of various ideas and algorithms put together. The
architecture is splitted into 3 parts, the filter management part, a layer
to abstract any kind of value and a set of keys to implement the actual
classification algorithms.

	The patch including the userspace tools can be found at
http://people.suug.ch/~tgr/egp/. Be warned, this is totally unfinished
work, some parts are not fully implemented yet it and still contains a lot
of known issues. Nevertheless, I think it is time to publish it.

	tcf_proto->root contains a list of classifiers adresseable by
their handle just like u32 or fw. One can add/remove to/from this
list or change existing classifiers. Every classifier holds any number
of keys arranged in a tree where every tree node contains a list of
keys interconnectable with AND and OR with a strict left-to-right
processing order. A key's result can be inverted. A classifier matches
if the logical expression is true. This basically allows to implement
any kind of logical expression. (a and b) or (c and d) would look like
this:

         x OR y
        /      \
   a AND b    c AND d

where x and y are dummy nodes representing the result of their child
nodes.

	The tree is implemented as array of key lists where a key
can point to another key list in the array. This simplifies the
transfer from userspace and allows to reuse parts of the tree.

	This is already quite powerful but isn't new and already
nearly doable with u32. The thing making the whole classifier
powerful is the value abstraction layer. Classyfing is all about
numbers, be it port numbers, ipv4 addresses, sequence numbers, dscp
values, interface indexes, classids, nfmark or simply results of a
matching procedure. The abstraction layer takes advantage of this and
hides all the different kinds of values and brings them down to a
simple integer. The following value types have been implemented:
  o Simple u32 value (read/write)
  o Metadata such as random value, input device, real device,
    load average, nr of running processes, tcindex, socket protocol,
    paket length, socket family, data len, netfilter mark, socket
    receive queue, socket priority, ack backlog, ...
  o Kernel global register values (read/write). Can be used to
    to communicate between ingress/egress.
  o Reference to another value
  o Classifier result (classid)
  o Result of key evaluation
  o Packet content, (u8/u6/u32) with support for layers, a mask
    and left/right shift to access single bits. The configuration
    parameters offet,mask,lshift,rshift are abstract values again
    which means offsets can be dynamically calculated.
  o Term to combine all of the above with support for precedence
    by making use of refeference so you can configure value such
    as (nfmark - register_2) >> (offset(u8 at 2@2 mask 0xf) * 4)

	In order to use the API, all the values must be defined in
an index must be assigned to them. Keys are given theses indeces
to access the value which basically means that a key has no knowledge
about where the data is comming from, all he gets is an integer.

	The actual matching is done in the keys. The following keys
have been implemented:

  o simple_cmp: Simple comparison of two values supporing eq, ne, lt
                le, gt, and ge. Sounds boring but the value abstraction
                makes this really powerful already.

  o nbyte: Compares a pattern against packet content at a specific offset.
           Intented for IPv6 address matching but can be used for any kind
           of pattern.

  o kmp: Knuth-Moriss-Pratt text search. Is basically equal to nbyte except
         that it looks for the pattern in a given range.

  o regexp: Very simple regular expression to match dynamic data. Supports
            wildcard, specific characters and various groups such as digit,
            xdigit, print, alpha, ... Allows recurrences of 1, 0..1, 0..n,
            and 1..n. That's it, very simple but fair enough for classification.

  o true: always true

  o cmd: Implements a pseudo machine similar to BPF. Processes a list of
         instructions with up to 3 arguments until a RET is processed or
         the tail of the list has been found. A hard limit of backward jumps
         can be configured to avoid endless loops. Supports all the basic
         calculation instructions, basic branching instructions and some
         specific instructions to convert numbers from network to host byte
         order and vice versa, shortcuts to make the filter match and an
         instruction to write a character or a number to the console.

That's all there is in the kernel part, describing the userspace part would
take just too long and it's probably easier if you look at examples/. Just
a few words, the configuration is done by writing a .egp file which is then
processed by a pre processor and converted to an XML based format which can
be loaded into the kernel with the ectl tool. The .egp language is fairly
intutitive and a mix of C, functional languages and assembler. The highlight
is probably the internal on-the-fly converter to convert a C like language
into the instruction set understood by the cmd key. I attached a small
example dumping the packet content like below to show how it can be abused.

-- Dumping 0x56 octets --
00 02 44 63 ca 27 00 02 44 63 ed 53 08 00 45 00  ..Dc.'..Dc.S..E.
00 48 47 4d 40 00 40 11 43 f9 c0 a8 17 01 c0 a8  .HGM@.@.C.......
17 0d 80 2f 00 35 00 34 15 f3 c9 4f 01 00 00 01  .../.5.4...O....
00 00 00 00 00 00 02 31 32 02 32 33 03 31 36 38  .......12.23.168
03 31 39 32 07 69 6e 2d 61 64 64 72 04 61 72 70  .192.in-addr.arp
61 00 00 0c 00 01                                a.....

Pay attention to the semicolon after the label, it's needed for now ;->

result default 0:0; /* default class */

off := 0;
pos := 1;
tmp := 0;

main() {
	cmd {
		puts("-- Dumping 0x");
		puti(%PKTLEN);
		puts(" octets --\n");
		for (off = 0, pos = 1; off < %PKTLEN; off++) {
			puti(offset(u8 at off@0));
			puts(" ");
			if (pos == 16) {
print_ascii:;
				puts(" ");
				while (pos > 0) {
					tmp = offset(u8 at {off-(pos-1)}@0);
					if (tmp >= 0x20) {
						if (tmp <= 0x7e)
							putc(tmp);
						else
							puts(".");
					} else
						puts(".");
					pos--;
				}
				puts("\n");
				pos = 1;
			} else
				pos++;
		}

		if (pos > 1) {
			for (tmp = pos; tmp <= 16; tmp++) {
				puts("   ");
			}
			off--;
			pos--;
			goto print_ascii;
		}

		puts("\n");
		return 1;
	}
}
