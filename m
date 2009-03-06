From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: Davicom DM9000A on MPC5200B (powerpc) works using a dirty
	offsetting and byte trick
Date: Fri, 6 Mar 2009 08:02:42 -0700
Message-ID: <fa686aa40903060702m3f955a32oe951e2a693553454@mail.gmail.com>
References: <ae4f76fd0902200151m461f9336x1e2bbec61f815fde@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Henk Stegeman <henk.stegeman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:46455 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373AbZCFPCo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 10:02:44 -0500
Received: by yx-out-2324.google.com with SMTP id 8so286424yxm.1
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2009 07:02:42 -0800 (PST)
In-Reply-To: <ae4f76fd0902200151m461f9336x1e2bbec61f815fde@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2009 at 2:51 AM, Henk Stegeman <henk.stegeman@gmail.com=
> wrote:
> I have the following definition for this network device in my dts:
>
> =A0 =A0 =A0 =A0enet1:ethernet@fb000000 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0#size-cells =3D <1>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0#address-cells =3D <1>;

The ethernet node doesn't have any children, so drop the #size-cells
and #address-cells properties.

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0device_type =3D "network";

Drop device_type too.  It only makes sense if you're running real OpenF=
irmware.

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compatible =3D "davicom,dm9000";
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D <0xfb000000 0x00000002 =A0 =A0=
 =A0 =A0 =A0 =A0// DM9000 Address register
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00xfb000002 0x00000002>=
; =A0 =A0 =A0 =A0 // DM9000 Data register

Just make this reg =3D <0xfb000000 0x00000004>;.  Specify in the
documentation for the "davicom,dm9000" binding that the address
register is at offset 0 and the data register is at offset 2.

Actually, since this is the local plus bus, you should have this node
as a child of the localplus node.  Like this:

localbus {
    compatible =3D "fsl,mpc5200b-lpb", "fsl,mpc5200-lpb", "simple-bus";
    #address-cells =3D <2>;  // first cell is CS#, second is offset
    #size-cells =3D <1>;
    ranges =3D <1 0 0xfb000000 0x4>;  // CS#1, offset 0, mapped to
0xfb000000, size=3D4
    enet1: ethernet@fb000000 {
        compatible =3D "davicom,dm9000";
        reg =3D <0xfb000000 0x00000002            // DM9000 Address reg=
ister
        mac-address =3D [ 00 00 00 00 00 00 ]; // Filled in by u-boot
        interrupts =3D <1 1 0>;                   // External interrupt=
 1
    };
};

Doing it this way provides drivers with the ability to get the chip
select number, which is important if you ever decide to use the
Localplus fifo to transfer to/from the device.

> To pass this information to the unmodified DM9000 driver I put
> together a wrapper arch/powerpc/sysdev/dm9000_dev.c (see below) for
> the of_ part (I reused most of the work from
> arch/powerpc/sysdev/tsi108_dev.c):
>
> Because the dm9000 driver uses the data address both as pointer to u1=
6
> and pointer to u8, this works for a little-endian cpu to the
> little-endian dm9000, but not for the big endian MPC5200 to little
> endian dm9000.
> So I add an offset of 1 to this pointer when it is passed to the
> dm9000 driver. This offset of 1 is wrong for the u16 accesses of the
> DM9000 driver, besides that the data needs to be byteswapped for the
> dm9000 driver.

If the driver cannot handle big endian machines, then it is a driver
bug.  Don't be afraid to modify the driver to fix this and send a
patch.

> For these two reasons I wrote the functions dm9000_outblk_16bit
> dm9000_intblk_16bit dm9000_dumpblk_16bit which are passed via the
> platform_data.
>
> Apart from comments on my assumptions I have the following questions
> about this situation and my code:
> - Is it the right way to make a separate arch/powerpc/sysdev/*_dev.c
> for reading the device-tree and passing it to a driver, in stead of
> adding it to the driver itself?

Personally, I'd use the of_platform bus infrastructure to probe the
new device.  Register an of_platform_driver which will bind against
the device node for the ethernet device.  Then you have a choice:
option 1)  Your driver's probe method can either create a child
platform device which the original driver can bind against with the
correct pdata, or
option 2) your new driver can call into the original driver at a point
that bypasses the platform bus bindings (because they are handled by
the of_platform bus instead).

I typically choose option 2 because it requires less overhead and less
memory (one fewer probe call and one fewer struct device), but it will
probably require a little bit of refactoring the original driver to
provide call points to bypass the platform bus binding bit of the
driver.  I've done this many times, but it does depend on the driver
maintainer being okay with multiple bus bindings (platform and
of_platform) for a driver.  This is an ongoing debate.

See drivers/video/xilinxfb.c for an example of a driver with both
platform and of_platform bus bindings.  You'll notice at the end of
the file that both a platform driver and an of_platform driver are
getting registered.

> - I think the best solution to handle the separate address and data
> register is the 2 entry register array in the device tree as above,
> this accounts for an odd connection to the DM9000's CMD pin. Agree?

no.  If CMD could appear at a different offset, then define an
optional property (maybe cmd-reg-offset =3D <2>;) to handle the case
where CMD appears at a different offset.

> - The MPC5200's chip-select can be configured to do byte-swapping on
> read and write, however when I configured it as such and I removed my
> offsetting by 1 and byte-swapping code It didn't work.
> - Any suggestions to what could be wrong here? Or does the MPC5200 in
> this case only byte swap u16 reads, but a u8 read is unchanged?

This I don't know.  I'd have to play with it to figure it out.

> - What about how the DM9000 driver deals with this u8 read and u16
> read, is this correct?

=46ix the driver.  It will result in a more useful driver for everyone
at the end of the day.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
