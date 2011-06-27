From: Sebastian.Poehn@Belden.com
Subject: Re: [PATCH] gianfar v5: implement nfc
Date: Mon, 27 Jun 2011 10:43:53 -0400
Message-ID: <OF0ADDB386.A2268AFF-ON852578BC.0050EC54-852578BC.0050EC5A@BeldenCDT.com>
References: <1308761280.10423.19.camel@Joe-Laptop>,
	<1308734972.7885.19.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev" <netdev@vger.kernel.org>
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.belden.com ([12.161.118.90]:45812 "EHLO mx1.belden.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051Ab1F0O64 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 10:58:56 -0400
In-Reply-To: <1308761280.10423.19.camel@Joe-Laptop>
MIME-Version: 1.0
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your feedback Joe!

> I'm a bit confused by this:

/*
=A0* What we already have:
=A0* A temporary copy of the filer table which will later replace the c=
urrent one.
=A0* In the filer table we always have one mask entry followed by a val=
ue (of action).
=A0* Further we have the mask table which is a list of all mask in the =
filer table.
=A0* To every entry we have the start and the end of the validity and a=
 block index
=A0* (same block indexes means dependency). We want to sort every depen=
dent block!
=A0*/
static void gfar_sort_mask_table(struct gfar_mask_entry *mask_table,
=A0=A0=A0 =A0=A0=A0 struct filer_table *temp_table, u32 and_index)
{
=A0=A0=A0 /* Pointer to compare function (_asc or _desc) */
=A0=A0=A0 int (*gfar_comp)(const void *, const void *);

=A0=A0=A0 u32 i, size =3D 0, start =3D 0, prev =3D 1;
=A0=A0=A0 u32 old_first, old_last, new_first, new_last;

=A0=A0=A0 gfar_comp =3D &gfar_comp_desc;

=A0=A0=A0 for (i =3D 0; i < and_index; i++) {
=A0=A0=A0 =A0=A0=A0 /* As long, as the block is the same (dependency) w=
e only increase
=A0=A0=A0 =A0=A0=A0 =A0* the size */
=A0=A0=A0 =A0=A0=A0 if (prev !=3D mask_table[i].block) {
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 /* The +1 is because=A0 start is a mask a=
nd the important
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0* FF80 information is located in the n=
ext value element */
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 old_first =3D mask_table[start].start + 1=
;
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 /* -1 because we are already at the start=
 of the next dependent block */
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 old_last =3D mask_table[i - 1].end;
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0=20
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 /* Here the mask table is sorted! So the =
entries in the current
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0* block change may change their locati=
on */
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 sort(mask_table + start, size,
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 sizeof(struct gfar_ma=
sk_entry),
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 gfar_comp, &gfar_swap=
);

=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 /* Toggle order for every block. This mak=
es the
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0* thing more efficient! */
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 if (gfar_comp =3D=3D gfar_comp_desc)
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 gfar_comp =3D &gfar_comp_asc;
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 else
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 gfar_comp =3D &gfar_comp_desc;
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 /* The same as above but the elements are=
 others because of the sorting */
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0=20
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 new_first =3D mask_table[start].start + 1=
;
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 new_last =3D mask_table[i - 1].end;

=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 gfar_swap_bits(&temp_table->fe[new_first]=
,
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 &temp_table->fe[old_f=
irst],
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 &temp_table->fe[new_l=
ast],
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 &temp_table->fe[old_l=
ast],
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 RQFCR_QUEUE | RQFCR_C=
LE |
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 RQFCR_RJE |=
 RQFCR_AND
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 );

=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 start =3D i;
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 size =3D 0;
=A0=A0=A0 =A0=A0=A0 }
=A0=A0=A0 =A0=A0=A0 size++;
=A0=A0=A0 =A0=A0=A0 prev =3D mask_table[i].block;
=A0=A0=A0 }

}

> Doesn't this just swap the same bits around twice?

Due to the masks are sorted numerically it is possible that a mask from=
 any location changes its locations to ANY. Lets think of this example =
and the usage of the sequential swapping:

A has a header     <- old_first               new position after sortin=
g: 2
B                  <- new_last                new position after sortin=
g: 4
C                                             new position after sortin=
g: 3
D has a trailer    <- old_last and new_first  new position after sortin=
g: 1

=46irst swap first:
A has a trailer
B
C
D has a header

Second swap:
A has a trailer
B has a header
C
D

And now after the sorted order is applied:
D
A has a trailer
C
B has a header

Thats not correct!

The concurrent swapper does:
A
B has a trailer
C
D has a header

And:
D has a header
A
C
B has a trailer

That's all right!








DISCLAIMER:

Privileged and/or Confidential information may be contained in this
message. If you are not the addressee of this message, you may not
copy, use or deliver this message to anyone. In such event, you
should destroy the message and kindly notify the sender by reply
e-mail. It is understood that opinions or conclusions that do not
relate to the official business of the company are neither given
nor endorsed by the company.

Thank You.

