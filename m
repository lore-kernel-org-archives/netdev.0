From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: iproute2 v6: full ss json support and general output simplification
Date: Wed,  9 Sep 2015 21:43:11 +0200
Message-ID: <1441827801-9617-1-git-send-email-matthias.tafelmeier@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:55683 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754651AbbIITnb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2015 15:43:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- add full JSON support for ss
- Patchset provides a general and easy to use abstraction to extend ss =
later
- Patchset size is large to minimize daily use ("user" should not deal =
with
  	formation (json, human readble) later on)
- Patches 7/10 and 8/10 illustrate how to extend ss for new data to sup=
port human readble and json
	output.=20
- Example_Usages: 1. ss -jt to print out all tcp related information fo=
rmatted in json
		  2. ss --json -a to print out all info (also summary)=20

STATS:

  ss: rooted out ss type declarations for output formatters
  ss: created formatters for json and hr
  ss: removed obsolet fmt functions
  ss: prepare timer for output handler usage
  ss: replaced old output with new generic output mechanisms
  ss: renaming and export of current_filter
  ss: symmetrical subhandler output extension example
  ss: symmetrical formatter extension example
  ss: fixed free on local array for valid json output
  ss: activate json_writer excluded logic

 include/json_writer.h |   1 +
 lib/json_writer.c     |   7 -
 misc/Makefile         |   2 +-
 misc/ss.c             | 971 +++++++++++++++++-------------------------=
--------
 misc/ss_hr_fmt.c      | 321 +++++++++++++++++
 misc/ss_hr_fmt.h      |   9 +
 misc/ss_json_fmt.c    | 475 ++++++++++++++++++++++++
 misc/ss_json_fmt.h    |  26 ++
 misc/ss_out_fmt.c     | 137 +++++++
 misc/ss_out_fmt.h     |  92 +++++
 misc/ss_types.h       | 186 ++++++++++
 11 files changed, 1567 insertions(+), 660 deletions(-)
 create mode 100644 misc/ss_hr_fmt.c
 create mode 100644 misc/ss_hr_fmt.h
 create mode 100644 misc/ss_json_fmt.c
 create mode 100644 misc/ss_json_fmt.h
 create mode 100644 misc/ss_out_fmt.c
 create mode 100644 misc/ss_out_fmt.h
 create mode 100644 misc/ss_types.h

--=20

Abstract:=20

This patch set originates from the necessity to upgrade ss with the pos=
sibility
to output in json format. Not to clutter up ss too much, the author of =
the
patch decided to come up with a simple distributor to handler approach.=
 That
is, the distributor poses the mechanical interface which passes the out=
put
requests coming from ss to the appropriate handler. This simplifies the
interaction with ss and provides a maximum of future extensiblity. Not =
to
forget, ss loses weight thereby since output implemented in ss itself d=
oes
migrate to the appropriate handler. Additionally, because types are sha=
red
amongst handlers, the distributor and ss, the author conceived, that a =
separate
containter module for types has to be formed. In future, all type decla=
rations
and extensins go there.=20

In sum, the patchset has this voluminous extent since there is no viabl=
e way
for putting out syntactically correct human readble and json in a simpl=
er manner.
The requirement for convenient extensibility of output and data is
another justification for the patchset size.

Concept sketch:

                                               formatter1=20
                                              ************             =
  =20
                                              *          *             =
  =20
                                              *          *             =
  =20
           ss                           ~~~~~~~>zzzzzzz  *             =
  =20
     ******************                 ~     *          *             =
  =20
     *                *                 ~   ###>fffffff  *             =
  =20
     *                *                 ~   # *          *             =
  =20
     *                *      distributor~   # ************             =
  =20
     *   --------     *       ********* ~   #                          =
  =20
     *   -    --------------  *       * ~   #                          =
  =20
     *   --------     *    -  *       * ~   #                          =
  =20
     *                *    ---->++++ ~~~~   #                          =
  =20
     *                *       *       * ~   #  formatter2=20
     *                *    ---->=3D=3D=3D=3D ######## ************     =
          =20
     *   --------     *    -  *       * ~   # *          *             =
  =20
     *   -    --------------  *       * ~   # *          *             =
  =20
     *   --------     *       ********* ~   # *          *             =
  =20
     *                *                 ~~~~#~~>zzzzzzz  *             =
  =20
     *                *                     # *          *             =
  =20
     *                *                     ###>fffffff	 *             =
  =20
     ******************                       *          *             =
  =20
                                              ************             =
  =20
						                      =20
At the moment, the distributor is the ss_out_fmt module while two handl=
ers are
up: namely the ss_json_fmt and the ss_hr_fmt (human readable). You can =
use
those modules as the main reference for own extensions.

=46uture Extension:
In the following, I will expand on the expandability of the formatter m=
odel.
The explanations advances from the minimal to the most sweeping extensi=
on in
mind.

Sub Format Handler Output=20
Sketch

		  FormatterX
                  ***********************************                  =
  =20
                  *                                 *                  =
  =20
                  *   handlerX 			    *                    =20
                  *   =C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0    *                    =20
                  *   =C2=B0                        =C2=B0    *        =
            =20
                  *   =C2=B0    xxxxxxxxxxxxxxc<..  =C2=B0    *        =
            =20
                  *   =C2=B0                     .  =C2=B0    *        =
            =20
                  *   =C2=B0    xxxxxxxxxxxxxxc<.. potential context   =
              =20
                  *   =C2=B0        new:         .  =C2=B0    *     =20
                  *   =C2=B0    +++++++++++++++... < * * * * * * * * * =
* *      =20
                  *   =C2=B0                        =C2=B0    *        =
       *     =20
                  *   =C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0    *               *     =20
                  *               .                 *               *  =
   =20
                  *               .                 *               *  =
   =20
                  *               .                 *               *  =
   =20
                  *   handlerY		  	    *               *     =20
                  *   =C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0    *               *     =20
                  *   =C2=B0                        =C2=B0    *        =
       *     =20
                  *   =C2=B0    xxxxxxxxxxxxxxx     =C2=B0    *        =
       *     =20
                  *   =C2=B0                        =C2=B0    *        =
       *     =20
                  *   =C2=B0    xxxxxxxxxxxxxxx     =C2=B0    *        =
       *     =20
                  *   =C2=B0                        =C2=B0    *        =
       *   expand symmetrically  =20
                  *   =C2=B0                        =C2=B0    *        =
       *     =20
                  *   =C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0    *               *     =20
                  *                                 *               *  =
   =20
                  *                                 *               *  =
   =20
                  *                                 *               *  =
   =20
                  ***********************************          	    *
								    *
		 		.				    *
				.				    *
				.				    *
				 				    *
		  FormatterY					    *
                  ***********************************               *  =
  =20
                  *                                 *               *  =
  =20
                  *   handlerX			    *               *     =20
                  *   =C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0    *               *     =20
                  *   =C2=B0                        =C2=B0    *        =
       *     =20
                  *   =C2=B0    zzzzzzzzzzzzzzc<..  =C2=B0    *        =
       *     =20
                  *   =C2=B0                     .  =C2=B0    *        =
       *     =20
                  *   =C2=B0    zzzzzzzzzzzzzzc<.. potential context   =
  *             =20
                  *   =C2=B0        new:         .  =C2=B0    *        =
       *    =20
                  *   =C2=B0    +++++++++++++++... < * * * * * * * * * =
* *    =20
                  *   =C2=B0                        =C2=B0    *        =
            =20
                  *   =C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0    *                    =20
                  *               .                 *                  =
  =20
                  *               .                 *                  =
  =20
                  *               .                 *                  =
  =20
                  *   handlerY		  	    *                    =20
                  *   =C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0    *                    =20
                  *   =C2=B0                        =C2=B0    *        =
            =20
                  *   =C2=B0    zzzzzzzzzzzzzzz     =C2=B0    *        =
            =20
                  *   =C2=B0                        =C2=B0    *        =
            =20
                  *   =C2=B0    zzzzzzzzzzzzzzz     =C2=B0    *        =
            =20
                  *   =C2=B0                        =C2=B0    *        =
            =20
                  *   =C2=B0                        =C2=B0    *        =
            =20
                  *   =C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=
=B0=C2=B0=C2=B0=C2=B0=C2=B0=C2=B0    *                    =20
                  *                                 *                  =
  =20
                  *                                 *                  =
  =20
                  ***********************************    =20

Explanation:
If you plan to expand a sub out handler function of a formatter, it
essentially boils down to adding a new printf with an according format =
and
probably a necessary predicate (condition). Nontheless, care must be ta=
ken not
to lose possible context interdependecies out of sight. An examble for =
the
latter would be the interdependecy of json coma setting terms =E2=80=93=
 in compound
types, you do need a coma between consecutive elements.

More important is the issue about symmetric extensions. Except for the
tcp_out_fmt function implementation =E2=80=93 where a macro (CHECK_FMT_=
ADAPT) is in
place to check for adaptions in the basic tcpstat data structure static=
ally =E2=80=93
no general programmatic approach is in place yet which would prevent as=
ymmetric
extensions. Up to someone devices a holistic solution, this patch relie=
s on the
extenders to deal with asymmetries. Is the aim to have a new output fea=
ture
available in all semantically related handlers of n different formatter=
s, then
the expander has to adapt n handlers as shown in the sketch above.

Extend with further Format Handler in Formatter
Sketch:
-provides symmetrical extension intendet


                                                       formatter1
                                                      /----------------=
----------\
                                                      |                =
          |
                                                      |    spec_handler=
X         |
                                                      |     ###########=
##### <** |
                                                      |     ###########=
#####   * |
             distributor                              |            .   =
        * |
           O-------------------------O                |            .   =
        * |
           |    centr_hub            |                |    new_spec_han=
dler    * |
           | ***>01111110--------------------------+  |     +++++++++++=
+++++<~ * |
           | *   02222220----------------------+   |  |     +++++++++++=
+++++ ~ * |
           | *                       |         |   |  |                =
      ~ * |
           | *                       |         |   |  |      handler_hu=
b1    ~ * |
           | *  _______________      |         |   +--------->0########=
#0****~** |
           | * |gen_handlerX   |     |         |      |	      0++++++++=
+0~~~~~   |
           | **********        |     |         |      |                =
          |
           | * |_______________|     |         |      |                =
          |
           | *         .             |         |      \----------------=
----------/
           | *         .             |         |                  .
           | *         .             |         |                  .
           | * +++++++++++++++++     |         |       formatterN .
           | ***new_gen_handler+     |         |      /----------------=
----------\
           |   +               +     |         |      |                =
          |
           |   +++++++++++++++++     |         |      |    spec_handler=
X         |
           |                         |         |      |     ###########=
##### <** |
           O-------------------------O         |      |     ###########=
#####   * |
                                               |      |            .   =
        * |
                                               |      |            .   =
        * |
                                               |      |    new_spec_han=
dler    * |
                                               |      |     +++++++++++=
+++++<~ * |
                                               |      |     +++++++++++=
+++++ ~ * |
                                               |      |                =
      ~ * |
                                               |      |      handler_hu=
bN    ~ * |
                                               +------------->0########=
#0****~** |
                                                      |	      0++++++++=
+0~~~~~   |
                                                      |                =
          |
                                                      |                =
          |
                                                      \----------------=
----------/


Explanation:
As the sketch shows, the distributor works with the help of virtual fun=
ction
pointer in order to act as a call flow switch. It switches to the appro=
riate
formatter module and its handlers depending on the chosen output format=
 by ss
command input.=20

So, to add a new formatter handler symmetrically (up to now that is the=
 only
sensibly conceivable case), the extender must implement a new generic h=
andler
in the distributor and the specific handlers in the formatters. Then th=
e hub
vtable structure type has to be broadend to contain the new function po=
inter
type for the generic handler. After that, he has to extend and update a=
ll
handler hubs with the new handlers location information (function point=
er). The
latter ensures the generic switching mechanism used by the generic hand=
ler
keeps to be upheld.

Example:
Let's say we want the new "foo" data for every output format retrievabl=
e via
ss. Up to now, we have the ss_out_fmt module as the distributor and two
specific handlers: for one the ss_hr_fmt and secondly the ss_json_fmt m=
odule.
So we need a specific handler implementation in ss_hr_fmt and ss_json_f=
mt
modules and after that update the corresponding vtables (handler_hubs) =
in the
modules.  After that, the distributor, namely ss_out_fmt module, has to=
 get a
generic handler that switches via its vtable hub to either the json for=
matter
or the human readable formatter, depending on what fmt_type has been ch=
osen by ss.
Before the vtables in the specific modules can be updated, struct fmt_o=
p_hub
which is found in ss_out_fmt's interface header has get extendend with =
the new
function pointer type.

As soon the new generic handler has been exported via the ss_out_fmt.h =
module
interface, ss can use the new fmt handler to print out info. It can sim=
ply call
the generic function and does not have to deal with formatting specific=
 issues.

Extend for another Formatter=20
Sketch:
The Sketch for handler extension should be sufficient for conveying the=
 concept.
Just think of another formatter after formatterN and a new entry in the=
 central
vtable of the distributor to reach this new formatter.

Explanation:
Nothing breathtaking has to be done when someone needs an new formatter=
 module
for let's be image =E2=80=93 out of pure hypothetical endeavors =E2=80=93=
 xml ss output. First,
implement the new formatter with all the offered interfaces in the
distributor. Register all handlers in the local specific vtable hub.
Then, register the local vtable hub in the generic vtable hub of the
distributor to reach your new handler when chosen. Provide the client
code - here ss - with a new fmt_type option acceptance. Before the
option can do anything, you have to declare the new fmt_type. That's
it. No further adaptions in ss would be necessary.
